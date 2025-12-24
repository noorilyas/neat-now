import React, { useState } from 'react';
import { UserPlus, Search, Edit, Trash2, Eye, ToggleLeft, ToggleRight, ClipboardList, Star } from 'lucide-react';
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

interface WorkersProps {
  workers: Worker[];
  onViewProfile: (workerId: string) => void;
  onEdit: (worker: Worker) => void;
  onDelete: (workerId: string) => void;
  onToggleStatus: (workerId: string) => void;
  onAddNew: () => void;
  onCreateTask: (workerId: string) => void;
  sortByRating?: boolean;
}

export function Workers({
  workers,
  onViewProfile,
  onEdit,
  onDelete,
  onToggleStatus,
  onAddNew,
  onCreateTask,
  sortByRating = false
}: WorkersProps) {
  const [searchQuery, setSearchQuery] = useState('');
  const [statusFilter, setStatusFilter] = useState<'all' | 'active' | 'inactive'>('all');
  const [zoneFilter, setZoneFilter] = useState<string>('all');

  // Get unique zones
  const zones = Array.from(new Set(workers.map(w => w.zone)));

  // Filter workers
  const filteredWorkers = workers.filter(worker => {
    const matchesSearch = worker.name.toLowerCase().includes(searchQuery.toLowerCase()) ||
                         worker.email.toLowerCase().includes(searchQuery.toLowerCase()) ||
                         worker.zone.toLowerCase().includes(searchQuery.toLowerCase());
    const matchesStatus = statusFilter === 'all' || 
                         (statusFilter === 'active' && worker.active) ||
                         (statusFilter === 'inactive' && !worker.active);
    const matchesZone = zoneFilter === 'all' || worker.zone === zoneFilter;
    
    return matchesSearch && matchesStatus && matchesZone;
  });

  // Sort workers by rating if sortByRating is true
  const sortedWorkers = sortByRating ? filteredWorkers.sort((a, b) => b.rating - a.rating) : filteredWorkers;

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex flex-col sm:flex-row items-start sm:items-center justify-between gap-4">
        <div>
          <h1 className="text-3xl text-white mb-2">Worker Management</h1>
          <p className="text-slate-400">Manage your cleanup workforce</p>
        </div>
        <button
          onClick={onAddNew}
          className="flex items-center gap-2 px-6 py-3 bg-gradient-to-r from-emerald-500 to-teal-600 text-white rounded-xl hover:shadow-xl hover:shadow-emerald-500/30 transition-all duration-300 transform hover:scale-[1.02]"
        >
          <UserPlus className="w-5 h-5" />
          Add New Worker
        </button>
      </div>

      {/* Stats Cards */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
        <div className="bg-slate-900/50 backdrop-blur-sm border border-slate-800 rounded-xl p-6">
          <p className="text-sm text-slate-400 mb-2">Total Workers</p>
          <p className="text-3xl text-white">{workers.length}</p>
        </div>
        <div className="bg-slate-900/50 backdrop-blur-sm border border-slate-800 rounded-xl p-6">
          <p className="text-sm text-slate-400 mb-2">Active Workers</p>
          <p className="text-3xl text-emerald-500">{workers.filter(w => w.active).length}</p>
        </div>
        <div className="bg-slate-900/50 backdrop-blur-sm border border-slate-800 rounded-xl p-6">
          <p className="text-sm text-slate-400 mb-2">Inactive Workers</p>
          <p className="text-3xl text-slate-500">{workers.filter(w => !w.active).length}</p>
        </div>
        <div className="bg-slate-900/50 backdrop-blur-sm border border-slate-800 rounded-xl p-6">
          <p className="text-sm text-slate-400 mb-2">Avg Rating</p>
          <div className="flex items-center gap-2">
            <p className="text-3xl text-white">
              {workers.length > 0 ? (workers.reduce((acc, w) => acc + w.rating, 0) / workers.length).toFixed(1) : '0.0'}
            </p>
            <Star className="w-6 h-6 text-yellow-500 fill-yellow-500" />
          </div>
        </div>
      </div>

      {/* Filters */}
      <div className="bg-slate-900/50 backdrop-blur-sm border border-slate-800 rounded-xl p-4">
        <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
          {/* Search */}
          <div className="md:col-span-2 relative">
            <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-5 h-5 text-slate-400" />
            <input
              type="text"
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              placeholder="Search workers by name, email, or zone..."
              className="w-full pl-10 pr-4 py-3 bg-slate-800/50 border border-slate-700 rounded-lg text-white placeholder-slate-500 focus:outline-none focus:border-emerald-500 focus:ring-2 focus:ring-emerald-500/20 transition-all"
            />
          </div>

          {/* Status Filter */}
          <div>
            <select
              value={statusFilter}
              onChange={(e) => setStatusFilter(e.target.value as any)}
              className="w-full px-4 py-3 bg-slate-800/50 border border-slate-700 rounded-lg text-white focus:outline-none focus:border-emerald-500 focus:ring-2 focus:ring-emerald-500/20 appearance-none cursor-pointer"
            >
              <option value="all">All Status</option>
              <option value="active">Active Only</option>
              <option value="inactive">Inactive Only</option>
            </select>
          </div>

          {/* Zone Filter */}
          <div>
            <select
              value={zoneFilter}
              onChange={(e) => setZoneFilter(e.target.value)}
              className="w-full px-4 py-3 bg-slate-800/50 border border-slate-700 rounded-lg text-white focus:outline-none focus:border-emerald-500 focus:ring-2 focus:ring-emerald-500/20 appearance-none cursor-pointer"
            >
              <option value="all">All Zones</option>
              {zones.map(zone => (
                <option key={zone} value={zone}>{zone}</option>
              ))}
            </select>
          </div>
        </div>
      </div>

      {/* Workers Table */}
      <div className="bg-slate-900/50 backdrop-blur-sm border border-slate-800 rounded-xl overflow-hidden">
        <div className="overflow-x-auto">
          <table className="w-full">
            <thead className="bg-slate-800/50 border-b border-slate-700">
              <tr>
                <th className="px-6 py-4 text-left text-xs text-slate-400 uppercase tracking-wider">Worker</th>
                <th className="px-6 py-4 text-left text-xs text-slate-400 uppercase tracking-wider">Contact</th>
                <th className="px-6 py-4 text-left text-xs text-slate-400 uppercase tracking-wider">Zone</th>
                <th className="px-6 py-4 text-left text-xs text-slate-400 uppercase tracking-wider">Rating</th>
                <th className="px-6 py-4 text-left text-xs text-slate-400 uppercase tracking-wider">Tasks</th>
                <th className="px-6 py-4 text-left text-xs text-slate-400 uppercase tracking-wider">Status</th>
                <th className="px-6 py-4 text-left text-xs text-slate-400 uppercase tracking-wider">Actions</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-800">
              {sortedWorkers.map((worker) => (
                <tr key={worker.id} className="hover:bg-slate-800/30 transition-colors">
                  {/* Worker Info with Image */}
                  <td className="px-6 py-4">
                    <div className="flex items-center gap-3">
                      <div className="w-12 h-12 rounded-full bg-gradient-to-br from-emerald-500 to-teal-600 flex items-center justify-center overflow-hidden">
                        {worker.image ? (
                          <ImageWithFallback
                            src={worker.image}
                            alt={worker.name}
                            className="w-full h-full object-cover"
                          />
                        ) : (
                          <span className="text-white">
                            {worker.name.split(' ').map(n => n[0]).join('').toUpperCase()}
                          </span>
                        )}
                      </div>
                      <div>
                        <p className="text-white">{worker.name}</p>
                        <p className="text-xs text-slate-400">{worker.id}</p>
                      </div>
                    </div>
                  </td>

                  {/* Contact */}
                  <td className="px-6 py-4">
                    <div>
                      <p className="text-sm text-slate-300">{worker.email}</p>
                      <p className="text-xs text-slate-500">{worker.phone}</p>
                    </div>
                  </td>

                  {/* Zone */}
                  <td className="px-6 py-4">
                    <span className="px-3 py-1 bg-slate-800 border border-slate-700 rounded-lg text-sm text-slate-300">
                      {worker.zone}
                    </span>
                  </td>

                  {/* Rating */}
                  <td className="px-6 py-4">
                    <div className="flex items-center gap-2">
                      <div className="flex items-center">
                        {[...Array(5)].map((_, i) => (
                          <Star
                            key={i}
                            className={`w-4 h-4 ${
                              i < Math.floor(worker.rating)
                                ? 'text-yellow-500 fill-yellow-500'
                                : 'text-slate-600'
                            }`}
                          />
                        ))}
                      </div>
                      <span className="text-sm text-slate-300">{worker.rating.toFixed(1)}</span>
                    </div>
                  </td>

                  {/* Tasks */}
                  <td className="px-6 py-4">
                    <div>
                      <p className="text-white">{worker.tasksCompleted}</p>
                      <p className="text-xs text-slate-500">{worker.avgCompletionTime}h avg</p>
                    </div>
                  </td>

                  {/* Status */}
                  <td className="px-6 py-4">
                    <span
                      className={`inline-flex items-center px-3 py-1 rounded-full text-xs border ${
                        worker.active
                          ? 'bg-green-500/20 text-green-500 border-green-500/30'
                          : 'bg-red-500/20 text-red-500 border-red-500/30'
                      }`}
                    >
                      {worker.active ? 'Active' : 'Inactive'}
                    </span>
                  </td>

                  {/* Actions */}
                  <td className="px-6 py-4">
                    <div className="flex items-center gap-2">
                      <button
                        onClick={() => onViewProfile(worker.id)}
                        className="p-2 text-emerald-500 hover:bg-emerald-500/10 rounded-lg transition-all"
                        title="View Profile"
                      >
                        <Eye className="w-4 h-4" />
                      </button>
                      <button
                        onClick={() => onCreateTask(worker.id)}
                        className="p-2 text-blue-500 hover:bg-blue-500/10 rounded-lg transition-all"
                        title="Create Task"
                      >
                        <ClipboardList className="w-4 h-4" />
                      </button>
                      <button
                        onClick={() => onEdit(worker)}
                        className="p-2 text-slate-400 hover:text-white hover:bg-slate-700 rounded-lg transition-all"
                        title="Edit"
                      >
                        <Edit className="w-4 h-4" />
                      </button>
                      <button
                        onClick={() => onToggleStatus(worker.id)}
                        className={`p-2 rounded-lg transition-all ${
                          worker.active
                            ? 'text-yellow-500 hover:bg-yellow-500/10'
                            : 'text-green-500 hover:bg-green-500/10'
                        }`}
                        title={worker.active ? 'Deactivate' : 'Activate'}
                      >
                        {worker.active ? <ToggleRight className="w-4 h-4" /> : <ToggleLeft className="w-4 h-4" />}
                      </button>
                      <button
                        onClick={() => onDelete(worker.id)}
                        className="p-2 text-red-500 hover:bg-red-500/10 rounded-lg transition-all"
                        title="Delete"
                      >
                        <Trash2 className="w-4 h-4" />
                      </button>
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>

          {sortedWorkers.length === 0 && (
            <div className="text-center py-12">
              <p className="text-slate-400">No workers found matching your filters.</p>
            </div>
          )}
        </div>
      </div>

      {/* Results Summary */}
      <div className="text-center text-sm text-slate-400">
        Showing {sortedWorkers.length} of {workers.length} workers
      </div>
    </div>
  );
}