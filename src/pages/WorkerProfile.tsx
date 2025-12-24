import React from 'react';
import { 
  ArrowLeft, 
  Mail, 
  Phone, 
  MapPin, 
  Star, 
  TrendingUp, 
  Clock, 
  CheckCircle2,
  RefreshCw,
  AlertCircle,
  Calendar,
  Activity
} from 'lucide-react';
import { ImageWithFallback } from '../components/figma/ImageWithFallback';

interface Worker {
  id: string;
  name: string;
  email: string;
  phone: string;
  zone: string;
  tasksCompleted: number;
  avgCompletionTime: number;
  rating: number;
  active: boolean;
  image?: string;
}

interface Report {
  id: string;
  location: string;
  status: string;
  submittedAt: Date;
  assignedAt?: Date;
  resolvedAt?: Date;
  wasteType: string;
}

interface ActivityLog {
  id: string;
  action: string;
  timestamp: Date;
  reportId?: string;
}

interface WorkerProfileProps {
  worker: Worker;
  currentAssignments: Report[];
  activityLog: ActivityLog[];
  onBack: () => void;
  onPasswordReset: (workerId: string) => void;
}

export function WorkerProfile({
  worker,
  currentAssignments,
  activityLog,
  onBack,
  onPasswordReset
}: WorkerProfileProps) {
  return (
    <div className="space-y-6">
      {/* Back Button */}
      <button
        onClick={onBack}
        className="flex items-center gap-2 text-slate-400 hover:text-white transition-colors"
      >
        <ArrowLeft className="w-5 h-5" />
        Back to Workers
      </button>

      {/* Profile Header */}
      <div className="bg-slate-900/50 backdrop-blur-sm border border-slate-800 rounded-xl overflow-hidden">
        <div className="h-32 bg-gradient-to-r from-emerald-500 to-teal-600"></div>
        <div className="px-8 pb-8">
          <div className="flex flex-col md:flex-row items-start md:items-end gap-6 -mt-16">
            {/* Profile Image */}
            <div className="w-32 h-32 rounded-2xl bg-slate-900 border-4 border-slate-900 overflow-hidden flex items-center justify-center">
              {worker.image ? (
                <ImageWithFallback
                  src={worker.image}
                  alt={worker.name}
                  className="w-full h-full object-cover"
                />
              ) : (
                <div className="w-full h-full bg-gradient-to-br from-emerald-500 to-teal-600 flex items-center justify-center">
                  <span className="text-4xl text-white">
                    {worker.name.split(' ').map(n => n[0]).join('').toUpperCase()}
                  </span>
                </div>
              )}
            </div>

            {/* Header Info */}
            <div className="flex-1 mt-4 md:mt-0">
              <div className="flex flex-col md:flex-row md:items-center md:justify-between gap-4">
                <div>
                  <h1 className="text-3xl text-white mb-2">{worker.name}</h1>
                  <p className="text-slate-400">{worker.id}</p>
                  <div className="flex items-center gap-2 mt-3">
                    <div className="flex items-center">
                      {[...Array(5)].map((_, i) => (
                        <Star
                          key={i}
                          className={`w-5 h-5 ${
                            i < Math.floor(worker.rating)
                              ? 'text-yellow-500 fill-yellow-500'
                              : 'text-slate-600'
                          }`}
                        />
                      ))}
                    </div>
                    <span className="text-white">{worker.rating.toFixed(1)}</span>
                    <span className="text-slate-500">Overall Rating</span>
                  </div>
                </div>

                {/* Status Badge */}
                <div className="flex items-center gap-3">
                  <span
                    className={`inline-flex items-center px-4 py-2 rounded-xl text-sm border ${
                      worker.active
                        ? 'bg-green-500/20 text-green-500 border-green-500/30'
                        : 'bg-red-500/20 text-red-500 border-red-500/30'
                    }`}
                  >
                    {worker.active ? '● Active' : '● Inactive'}
                  </span>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>

      {/* Contact Information */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        <div className="bg-slate-900/50 backdrop-blur-sm border border-slate-800 rounded-xl p-6">
          <div className="flex items-center gap-3 mb-3">
            <div className="w-10 h-10 rounded-lg bg-emerald-500/20 flex items-center justify-center">
              <Mail className="w-5 h-5 text-emerald-500" />
            </div>
            <p className="text-sm text-slate-400">Email</p>
          </div>
          <p className="text-white">{worker.email}</p>
        </div>

        <div className="bg-slate-900/50 backdrop-blur-sm border border-slate-800 rounded-xl p-6">
          <div className="flex items-center gap-3 mb-3">
            <div className="w-10 h-10 rounded-lg bg-blue-500/20 flex items-center justify-center">
              <Phone className="w-5 h-5 text-blue-500" />
            </div>
            <p className="text-sm text-slate-400">Phone</p>
          </div>
          <p className="text-white">{worker.phone}</p>
        </div>

        <div className="bg-slate-900/50 backdrop-blur-sm border border-slate-800 rounded-xl p-6">
          <div className="flex items-center gap-3 mb-3">
            <div className="w-10 h-10 rounded-lg bg-purple-500/20 flex items-center justify-center">
              <MapPin className="w-5 h-5 text-purple-500" />
            </div>
            <p className="text-sm text-slate-400">Assigned Zone</p>
          </div>
          <p className="text-white">{worker.zone}</p>
        </div>
      </div>

      {/* Performance Metrics */}
      <div className="bg-slate-900/50 backdrop-blur-sm border border-slate-800 rounded-xl p-6">
        <h2 className="text-xl text-white mb-6 flex items-center gap-2">
          <TrendingUp className="w-6 h-6 text-emerald-500" />
          Performance Metrics
        </h2>
        <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
          <div className="bg-slate-800/30 rounded-lg p-6 border border-slate-700">
            <div className="flex items-center justify-between mb-3">
              <p className="text-sm text-slate-400">Total Resolved Reports</p>
              <CheckCircle2 className="w-5 h-5 text-green-500" />
            </div>
            <p className="text-3xl text-white mb-2">{worker.tasksCompleted}</p>
            <p className="text-xs text-slate-500">All time</p>
          </div>

          <div className="bg-slate-800/30 rounded-lg p-6 border border-slate-700">
            <div className="flex items-center justify-between mb-3">
              <p className="text-sm text-slate-400">Average Resolution Time</p>
              <Clock className="w-5 h-5 text-blue-500" />
            </div>
            <p className="text-3xl text-white mb-2">{worker.avgCompletionTime}h</p>
            <p className="text-xs text-slate-500">Per task</p>
          </div>

          <div className="bg-slate-800/30 rounded-lg p-6 border border-slate-700">
            <div className="flex items-center justify-between mb-3">
              <p className="text-sm text-slate-400">Success Rate</p>
              <Star className="w-5 h-5 text-yellow-500" />
            </div>
            <p className="text-3xl text-white mb-2">
              {worker.tasksCompleted > 0 ? ((worker.rating / 5) * 100).toFixed(0) : '0'}%
            </p>
            <p className="text-xs text-slate-500">Based on rating</p>
          </div>
        </div>
      </div>

      {/* Current Assignments */}
      <div className="bg-slate-900/50 backdrop-blur-sm border border-slate-800 rounded-xl p-6">
        <h2 className="text-xl text-white mb-6 flex items-center gap-2">
          <AlertCircle className="w-6 h-6 text-yellow-500" />
          Current Assignments ({currentAssignments.length})
        </h2>
        {currentAssignments.length > 0 ? (
          <div className="space-y-3">
            {currentAssignments.map((assignment) => (
              <div
                key={assignment.id}
                className="bg-slate-800/30 rounded-lg p-4 border border-slate-700 hover:border-slate-600 transition-all"
              >
                <div className="flex items-start justify-between gap-4">
                  <div className="flex-1">
                    <div className="flex items-center gap-3 mb-2">
                      <span className="text-white">{assignment.id}</span>
                      <span
                        className={`px-2 py-1 rounded text-xs ${
                          assignment.status === 'Assigned'
                            ? 'bg-yellow-500/20 text-yellow-500'
                            : 'bg-blue-500/20 text-blue-500'
                        }`}
                      >
                        {assignment.status}
                      </span>
                      <span className="px-2 py-1 rounded text-xs bg-slate-700 text-slate-300">
                        {assignment.wasteType}
                      </span>
                    </div>
                    <p className="text-sm text-slate-400 flex items-center gap-2">
                      <MapPin className="w-4 h-4" />
                      {assignment.location}
                    </p>
                  </div>
                  <div className="text-right text-sm text-slate-500">
                    <p className="flex items-center gap-1">
                      <Calendar className="w-4 h-4" />
                      {assignment.assignedAt?.toLocaleDateString()}
                    </p>
                  </div>
                </div>
              </div>
            ))}
          </div>
        ) : (
          <div className="text-center py-8 text-slate-400">
            <AlertCircle className="w-12 h-12 mx-auto mb-3 text-slate-600" />
            <p>No current assignments</p>
          </div>
        )}
      </div>

      {/* Activity Log */}
      <div className="bg-slate-900/50 backdrop-blur-sm border border-slate-800 rounded-xl p-6">
        <h2 className="text-xl text-white mb-6 flex items-center gap-2">
          <Activity className="w-6 h-6 text-emerald-500" />
          Activity Log
        </h2>
        <div className="space-y-3">
          {activityLog.map((log, index) => (
            <div
              key={log.id}
              className="flex items-start gap-4 pb-3 border-b border-slate-800 last:border-0"
            >
              <div className="w-2 h-2 rounded-full bg-emerald-500 mt-2"></div>
              <div className="flex-1">
                <p className="text-sm text-slate-300">{log.action}</p>
                {log.reportId && (
                  <p className="text-xs text-slate-500 mt-1">Report: {log.reportId}</p>
                )}
              </div>
              <div className="text-xs text-slate-500 whitespace-nowrap">
                {log.timestamp.toLocaleString()}
              </div>
            </div>
          ))}
        </div>
      </div>

      {/* Admin Controls */}
      <div className="bg-gradient-to-r from-orange-500/10 to-red-500/10 border border-orange-500/20 rounded-xl p-6">
        <h2 className="text-xl text-white mb-4 flex items-center gap-2">
          <RefreshCw className="w-6 h-6 text-orange-500" />
          Admin Controls
        </h2>
        <p className="text-sm text-slate-400 mb-6">
          Sensitive actions that affect the worker's account access and security.
        </p>
        <div className="flex flex-wrap gap-4">
          <button
            onClick={() => onPasswordReset(worker.id)}
            className="flex items-center gap-2 px-6 py-3 bg-orange-500/20 hover:bg-orange-500/30 border border-orange-500/30 text-orange-500 rounded-lg transition-all"
          >
            <RefreshCw className="w-4 h-4" />
            Reset Password
          </button>
          <button className="flex items-center gap-2 px-6 py-3 bg-slate-800 hover:bg-slate-700 border border-slate-700 text-white rounded-lg transition-all">
            <Mail className="w-4 h-4" />
            Send Notification
          </button>
        </div>
      </div>
    </div>
  );
}
