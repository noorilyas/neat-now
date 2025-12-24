import React, { useState } from 'react';
import { Search, Filter, ChevronDown, Eye, CheckCircle2, XCircle } from 'lucide-react';
import { Report, Worker, ReportStatus, WasteType } from '../types';

interface ReportsViewProps {
  reports: Report[];
  workers: Worker[];
  statusFilter: ReportStatus | 'All';
  setStatusFilter: (value: ReportStatus | 'All') => void;
  workerFilter: string;
  setWorkerFilter: (value: string) => void;
  zoneFilter: string;
  setZoneFilter: (value: string) => void;
  wasteTypeFilter: WasteType | 'All';
  setWasteTypeFilter: (value: WasteType | 'All') => void;
  searchQuery: string;
  setSearchQuery: (value: string) => void;
  dateRange: { start: string; end: string };
  setDateRange: (value: { start: string; end: string }) => void;
  onSelectReport: (report: Report) => void;
}

export function ReportsView({
  reports,
  workers,
  statusFilter,
  setStatusFilter,
  workerFilter,
  setWorkerFilter,
  zoneFilter,
  setZoneFilter,
  wasteTypeFilter,
  setWasteTypeFilter,
  searchQuery,
  setSearchQuery,
  dateRange,
  setDateRange,
  onSelectReport
}: ReportsViewProps) {
  const [showFilters, setShowFilters] = useState(false);
  
  const uniqueWorkers = Array.from(new Set(reports.map((r: Report) => r.workerName).filter(Boolean)));
  const uniqueZones = Array.from(new Set(reports.map((r: Report) => r.zone)));
  
  return (
    <div className="space-y-4">
      {/* Filter Bar */}
      <div className="bg-slate-900/50 backdrop-blur-sm border border-slate-800 rounded-xl p-4">
        <div className="flex flex-col lg:flex-row gap-4">
          <div className="flex-1 relative">
            <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-5 h-5 text-slate-400" />
            <input
              type="text"
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              placeholder="Search by ID or location..."
              className="w-full pl-10 pr-4 py-2 bg-slate-800/50 border border-slate-700 rounded-lg text-white placeholder-slate-500 focus:outline-none focus:border-emerald-500 focus:ring-2 focus:ring-emerald-500/20 transition-all"
            />
          </div>
          
          <button
            onClick={() => setShowFilters(!showFilters)}
            className="flex items-center gap-2 px-4 py-2 bg-slate-800 hover:bg-slate-700 border border-slate-700 text-white rounded-lg transition-all"
          >
            <Filter className="w-4 h-4" />
            Filters
            <ChevronDown className={`w-4 h-4 transition-transform ${showFilters ? 'rotate-180' : ''}`} />
          </button>
        </div>
        
        {showFilters && (
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4 mt-4 pt-4 border-t border-slate-800">
            <FilterSelect
              label="Status"
              value={statusFilter}
              onChange={setStatusFilter}
              options={['All', 'Pending', 'Assigned', 'Resolved', 'Overdue']}
            />
            <FilterSelect
              label="Worker"
              value={workerFilter}
              onChange={setWorkerFilter}
              options={['All', ...uniqueWorkers]}
            />
            <FilterSelect
              label="Zone"
              value={zoneFilter}
              onChange={setZoneFilter}
              options={['All', ...uniqueZones]}
            />
            <FilterSelect
              label="Waste Type"
              value={wasteTypeFilter}
              onChange={setWasteTypeFilter}
              options={['All', 'Organic', 'Recyclable', 'Hazardous', 'General']}
            />
            <div>
              <label className="block text-sm text-slate-400 mb-2">Date From</label>
              <input
                type="date"
                value={dateRange.start}
                onChange={(e) => setDateRange({ ...dateRange, start: e.target.value })}
                className="w-full px-3 py-2 bg-slate-800/50 border border-slate-700 rounded-lg text-white focus:outline-none focus:border-emerald-500 focus:ring-2 focus:ring-emerald-500/20"
              />
            </div>
            <div>
              <label className="block text-sm text-slate-400 mb-2">Date To</label>
              <input
                type="date"
                value={dateRange.end}
                onChange={(e) => setDateRange({ ...dateRange, end: e.target.value })}
                className="w-full px-3 py-2 bg-slate-800/50 border border-slate-700 rounded-lg text-white focus:outline-none focus:border-emerald-500 focus:ring-2 focus:ring-emerald-500/20"
              />
            </div>
          </div>
        )}
      </div>
      
      {/* Results Count */}
      <div className="flex items-center justify-between">
        <p className="text-sm text-slate-400">
          Showing {reports.length} {reports.length === 1 ? 'report' : 'reports'}
        </p>
      </div>
      
      {/* Reports Table */}
      <div className="bg-slate-900/50 backdrop-blur-sm border border-slate-800 rounded-xl overflow-hidden">
        <div className="overflow-x-auto">
          <table className="w-full">
            <thead className="bg-slate-800/50 border-b border-slate-700">
              <tr>
                <th className="px-4 py-3 text-left text-xs text-slate-400 uppercase tracking-wider">Report ID</th>
                <th className="px-4 py-3 text-left text-xs text-slate-400 uppercase tracking-wider">Citizen</th>
                <th className="px-4 py-3 text-left text-xs text-slate-400 uppercase tracking-wider">Worker</th>
                <th className="px-4 py-3 text-left text-xs text-slate-400 uppercase tracking-wider">Location</th>
                <th className="px-4 py-3 text-left text-xs text-slate-400 uppercase tracking-wider">Status</th>
                <th className="px-4 py-3 text-left text-xs text-slate-400 uppercase tracking-wider">Submitted</th>
                <th className="px-4 py-3 text-left text-xs text-slate-400 uppercase tracking-wider">AI Verified</th>
                <th className="px-4 py-3 text-left text-xs text-slate-400 uppercase tracking-wider">Actions</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-800">
              {reports.map((report: Report) => (
                <tr key={report.id} className="hover:bg-slate-800/30 transition-colors">
                  <td className="px-4 py-3 text-sm text-white">{report.id}</td>
                  <td className="px-4 py-3 text-sm text-slate-300">{report.citizenName}</td>
                  <td className="px-4 py-3 text-sm text-slate-300">{report.workerName || '—'}</td>
                  <td className="px-4 py-3 text-sm text-slate-300 max-w-xs truncate">{report.location}</td>
                  <td className="px-4 py-3">
                    <StatusBadge status={report.status} />
                  </td>
                  <td className="px-4 py-3 text-sm text-slate-400">
                    {report.submittedAt.toLocaleDateString()}
                  </td>
                  <td className="px-4 py-3">
                    {report.aiVerification.verified ? (
                      <div className="flex items-center gap-1 text-green-500">
                        <CheckCircle2 className="w-4 h-4" />
                        <span className="text-xs">{report.aiVerification.confidence.toFixed(0)}%</span>
                      </div>
                    ) : (
                      <div className="flex items-center gap-1 text-red-500">
                        <XCircle className="w-4 h-4" />
                        <span className="text-xs">Failed</span>
                      </div>
                    )}
                  </td>
                  <td className="px-4 py-3">
                    <button
                      onClick={() => onSelectReport(report)}
                      className="p-2 text-slate-400 hover:text-white hover:bg-slate-700 rounded-lg transition-all"
                    >
                      <Eye className="w-4 h-4" />
                    </button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
}

// Filter Select Component
function FilterSelect({ label, value, onChange, options }: any) {
  return (
    <div>
      <label className="block text-sm text-slate-400 mb-2">{label}</label>
      <select
        value={value}
        onChange={(e) => onChange(e.target.value)}
        className="w-full px-3 py-2 bg-slate-800/50 border border-slate-700 rounded-lg text-white focus:outline-none focus:border-emerald-500 focus:ring-2 focus:ring-emerald-500/20 appearance-none cursor-pointer"
      >
        {options.map((opt: string) => (
          <option key={opt} value={opt}>{opt}</option>
        ))}
      </select>
    </div>
  );
}

// Status Badge Component
function StatusBadge({ status }: { status: ReportStatus }) {
  const styles = {
    Pending: 'bg-red-500/20 text-red-500 border-red-500/30',
    Assigned: 'bg-yellow-500/20 text-yellow-500 border-yellow-500/30',
    Resolved: 'bg-green-500/20 text-green-500 border-green-500/30',
    Overdue: 'bg-red-600/20 text-red-600 border-red-600/30'
  };
  
  return (
    <span className={`inline-flex items-center px-2 py-1 rounded text-xs border ${styles[status]}`}>
      {status}
    </span>
  );
}