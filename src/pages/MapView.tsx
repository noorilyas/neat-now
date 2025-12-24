import React, { useState } from 'react';
import { MapPin, TrendingUp, BarChart } from 'lucide-react';
import { BarChart as RechartsBarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer } from 'recharts';
import { Report } from '../types';

interface MapViewProps {
  reports: Report[];
  trendData: any[];
}

export function MapView({ reports, trendData }: MapViewProps) {
  const [selectedZone, setSelectedZone] = useState('All');
  
  const zones = ['All', ...Array.from(new Set(reports.map(r => r.zone)))];
  
  const zoneData = zones.slice(1).map(zone => ({
    zone,
    reports: reports.filter(r => r.zone === zone).length,
    pending: reports.filter(r => r.zone === zone && r.status === 'Pending').length,
    resolved: reports.filter(r => r.zone === zone && r.status === 'Resolved').length
  }));
  
  const filteredReports = selectedZone === 'All' 
    ? reports 
    : reports.filter(r => r.zone === selectedZone);
  
  return (
    <div className="space-y-6">
      {/* Zone Filter */}
      <div className="bg-slate-900/50 backdrop-blur-sm border border-slate-800 rounded-xl p-4">
        <div className="flex items-center gap-4">
          <MapPin className="w-5 h-5 text-emerald-500" />
          <div className="flex-1">
            <label className="block text-sm text-slate-400 mb-2">Filter by Zone</label>
            <select
              value={selectedZone}
              onChange={(e) => setSelectedZone(e.target.value)}
              className="w-full max-w-xs px-4 py-2 bg-slate-800/50 border border-slate-700 rounded-lg text-white focus:outline-none focus:border-emerald-500 focus:ring-2 focus:ring-emerald-500/20"
            >
              {zones.map(zone => (
                <option key={zone} value={zone}>{zone}</option>
              ))}
            </select>
          </div>
        </div>
      </div>
      
      {/* Map Placeholder & Analytics */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {/* Map Placeholder */}
        <div className="bg-slate-900/50 backdrop-blur-sm border border-slate-800 rounded-xl p-6">
          <h3 className="text-white mb-4 flex items-center gap-2">
            <MapPin className="w-5 h-5 text-emerald-500" />
            Geographic Distribution
          </h3>
          <div className="aspect-video bg-slate-800/50 rounded-lg border border-slate-700 flex items-center justify-center">
            <div className="text-center">
              <MapPin className="w-12 h-12 text-slate-600 mx-auto mb-3" />
              <p className="text-slate-400 mb-2">Interactive Map View</p>
              <p className="text-sm text-slate-500">
                Showing {filteredReports.length} reports
                {selectedZone !== 'All' && ` in ${selectedZone}`}
              </p>
            </div>
          </div>
          
          {/* Legend */}
          <div className="mt-4 grid grid-cols-2 gap-3">
            <div className="flex items-center gap-2">
              <div className="w-3 h-3 rounded-full bg-red-500"></div>
              <span className="text-sm text-slate-300">Pending</span>
            </div>
            <div className="flex items-center gap-2">
              <div className="w-3 h-3 rounded-full bg-yellow-500"></div>
              <span className="text-sm text-slate-300">Assigned</span>
            </div>
            <div className="flex items-center gap-2">
              <div className="w-3 h-3 rounded-full bg-green-500"></div>
              <span className="text-sm text-slate-300">Resolved</span>
            </div>
            <div className="flex items-center gap-2">
              <div className="w-3 h-3 rounded-full bg-red-600"></div>
              <span className="text-sm text-slate-300">Overdue</span>
            </div>
          </div>
        </div>
        
        {/* Zone Analytics */}
        <div className="bg-slate-900/50 backdrop-blur-sm border border-slate-800 rounded-xl p-6">
          <h3 className="text-white mb-4 flex items-center gap-2">
            <BarChart className="w-5 h-5 text-emerald-500" />
            Zone Analytics
          </h3>
          <ResponsiveContainer width="100%" height={300}>
            <RechartsBarChart data={zoneData}>
              <CartesianGrid strokeDasharray="3 3" stroke="#334155" />
              <XAxis dataKey="zone" stroke="#94a3b8" />
              <YAxis stroke="#94a3b8" />
              <Tooltip 
                contentStyle={{ 
                  backgroundColor: '#1e293b', 
                  border: '1px solid #334155',
                  borderRadius: '8px',
                  color: '#fff'
                }} 
              />
              <Bar dataKey="reports" fill="#10b981" />
              <Bar dataKey="pending" fill="#ef4444" />
              <Bar dataKey="resolved" fill="#06b6d4" />
            </RechartsBarChart>
          </ResponsiveContainer>
        </div>
      </div>
      
      {/* Hotspot Areas */}
      <div className="bg-slate-900/50 backdrop-blur-sm border border-slate-800 rounded-xl p-6">
        <h3 className="text-white mb-4 flex items-center gap-2">
          <TrendingUp className="w-5 h-5 text-emerald-500" />
          Hotspot Areas
        </h3>
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
          {zoneData.slice(0, 4).map((zone, index) => (
            <div key={zone.zone} className="bg-slate-800/30 rounded-lg p-4 border border-slate-700/50">
              <div className="flex items-center justify-between mb-2">
                <h4 className="text-white">{zone.zone}</h4>
                <span className={`text-xs px-2 py-1 rounded ${
                  index === 0 ? 'bg-red-500/20 text-red-500' : 'bg-slate-700/50 text-slate-400'
                }`}>
                  {index === 0 ? 'High' : 'Medium'}
                </span>
              </div>
              <div className="space-y-1">
                <p className="text-sm text-slate-400">Total: {zone.reports}</p>
                <p className="text-sm text-slate-400">Pending: {zone.pending}</p>
                <p className="text-sm text-slate-400">Resolved: {zone.resolved}</p>
              </div>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}