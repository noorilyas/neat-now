import React, { useState } from 'react';
import { X, MapPin, Calendar, User, CheckCircle2, AlertCircle } from 'lucide-react';
import { Report, Worker, ReportStatus } from '../types';

interface ReportDetailModalProps {
  report: Report;
  workers: Worker[];
  onClose: () => void;
  onAssign: (reportId: string, workerId: string) => void;
  onOverrideStatus: (reportId: string, status: ReportStatus) => void;
}

export function ReportDetailModal({ report, workers, onClose, onAssign, onOverrideStatus }: ReportDetailModalProps) {
  const [selectedWorker, setSelectedWorker] = useState(report.workerId || '');
  const [selectedStatus, setSelectedStatus] = useState(report.status);
  
  const handleAssign = () => {
    if (selectedWorker) {
      onAssign(report.id, selectedWorker);
      onClose();
    }
  };
  
  const handleStatusChange = () => {
    if (selectedStatus !== report.status) {
      onOverrideStatus(report.id, selectedStatus);
      onClose();
    }
  };
  
  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/60 backdrop-blur-sm">
      <div className="bg-slate-900 border border-slate-800 rounded-2xl max-w-4xl w-full max-h-[90vh] overflow-y-auto">
        {/* Header */}
        <div className="sticky top-0 bg-slate-900/95 backdrop-blur-sm border-b border-slate-800 px-6 py-4 flex items-center justify-between">
          <div>
            <h2 className="text-2xl text-white">Report Details</h2>
            <p className="text-sm text-slate-400 mt-1">{report.id}</p>
          </div>
          <button
            onClick={onClose}
            className="p-2 text-slate-400 hover:text-white hover:bg-slate-800 rounded-lg transition-all"
          >
            <X className="w-5 h-5" />
          </button>
        </div>
        
        {/* Content */}
        <div className="p-6 space-y-6">
          {/* Images */}
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div>
              <label className="block text-sm text-slate-400 mb-2">Before Image</label>
              <img 
                src={report.beforeImage} 
                alt="Before" 
                className="w-full h-64 object-cover rounded-lg border border-slate-700"
              />
            </div>
            {report.afterImage && (
              <div>
                <label className="block text-sm text-slate-400 mb-2">After Image</label>
                <img 
                  src={report.afterImage} 
                  alt="After" 
                  className="w-full h-64 object-cover rounded-lg border border-slate-700"
                />
              </div>
            )}
          </div>
          
          {/* Details Grid */}
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            <div className="space-y-4">
              <div>
                <label className="block text-sm text-slate-400 mb-2">
                  <User className="w-4 h-4 inline mr-1" />
                  Submitted By
                </label>
                <p className="text-white">{report.citizenName}</p>
                <p className="text-sm text-slate-400">{report.citizenId}</p>
              </div>
              
              <div>
                <label className="block text-sm text-slate-400 mb-2">
                  <MapPin className="w-4 h-4 inline mr-1" />
                  Location
                </label>
                <p className="text-white">{report.location}</p>
                <p className="text-sm text-slate-400">{report.zone}</p>
              </div>
              
              <div>
                <label className="block text-sm text-slate-400 mb-2">
                  <Calendar className="w-4 h-4 inline mr-1" />
                  Timeline
                </label>
                <div className="space-y-1">
                  <p className="text-sm text-white">
                    Submitted: {report.submittedAt.toLocaleString()}
                  </p>
                  {report.assignedAt && (
                    <p className="text-sm text-white">
                      Assigned: {report.assignedAt.toLocaleString()}
                    </p>
                  )}
                  {report.resolvedAt && (
                    <p className="text-sm text-white">
                      Resolved: {report.resolvedAt.toLocaleString()}
                    </p>
                  )}
                </div>
              </div>
            </div>
            
            <div className="space-y-4">
              <div>
                <label className="block text-sm text-slate-400 mb-2">Waste Type</label>
                <p className="text-white">{report.wasteType}</p>
              </div>
              
              <div>
                <label className="block text-sm text-slate-400 mb-2">
                  AI Verification
                </label>
                {report.aiVerification.verified ? (
                  <div className="flex items-center gap-2 text-green-500">
                    <CheckCircle2 className="w-5 h-5" />
                    <span>Verified ({report.aiVerification.confidence.toFixed(1)}% confidence)</span>
                  </div>
                ) : (
                  <div className="flex items-center gap-2 text-red-500">
                    <AlertCircle className="w-5 h-5" />
                    <span>Not Verified</span>
                  </div>
                )}
              </div>
              
              <div>
                <label className="block text-sm text-slate-400 mb-2">Description</label>
                <p className="text-white">{report.description}</p>
              </div>
              
              <div>
                <label className="block text-sm text-slate-400 mb-2">Urgency Level</label>
                <div className="flex items-center gap-2">
                  <div className="flex-1 bg-slate-800 rounded-full h-2">
                    <div 
                      className="bg-gradient-to-r from-yellow-500 to-red-500 h-2 rounded-full"
                      style={{ width: `${report.urgency * 10}%` }}
                    ></div>
                  </div>
                  <span className="text-white">{report.urgency}/10</span>
                </div>
              </div>
            </div>
          </div>
          
          {/* Assignment & Status */}
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6 pt-6 border-t border-slate-800">
            <div>
              <label className="block text-sm text-slate-400 mb-3">Assign Worker</label>
              <select
                value={selectedWorker}
                onChange={(e) => setSelectedWorker(e.target.value)}
                className="w-full px-4 py-3 bg-slate-800/50 border border-slate-700 rounded-xl text-white focus:outline-none focus:border-emerald-500 focus:ring-2 focus:ring-emerald-500/20"
              >
                <option value="">Select a worker...</option>
                {workers.filter(w => w.active).map(worker => (
                  <option key={worker.id} value={worker.id}>
                    {worker.name} - {worker.zone}
                  </option>
                ))}
              </select>
              <button
                onClick={handleAssign}
                disabled={!selectedWorker || selectedWorker === report.workerId}
                className="w-full mt-3 px-4 py-3 bg-gradient-to-r from-emerald-500 to-teal-600 text-white rounded-xl hover:shadow-xl hover:shadow-emerald-500/30 transition-all duration-300 disabled:opacity-50 disabled:cursor-not-allowed"
              >
                Assign Worker
              </button>
            </div>
            
            <div>
              <label className="block text-sm text-slate-400 mb-3">Override Status</label>
              <select
                value={selectedStatus}
                onChange={(e) => setSelectedStatus(e.target.value as ReportStatus)}
                className="w-full px-4 py-3 bg-slate-800/50 border border-slate-700 rounded-xl text-white focus:outline-none focus:border-emerald-500 focus:ring-2 focus:ring-emerald-500/20"
              >
                <option value="Pending">Pending</option>
                <option value="Assigned">Assigned</option>
                <option value="Resolved">Resolved</option>
                <option value="Overdue">Overdue</option>
              </select>
              <button
                onClick={handleStatusChange}
                disabled={selectedStatus === report.status}
                className="w-full mt-3 px-4 py-3 bg-slate-800 hover:bg-slate-700 text-white rounded-xl transition-all disabled:opacity-50 disabled:cursor-not-allowed"
              >
                Update Status
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}