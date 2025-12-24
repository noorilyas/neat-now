import React, { useState } from 'react';
import { X, MapPin, AlertTriangle } from 'lucide-react';

interface Worker {
  id: string;
  name: string;
  zone: string;
}

interface CreateTaskModalProps {
  worker: Worker | null;
  workers: Worker[];
  onClose: () => void;
  onCreate: (task: {
    workerId: string;
    location: string;
    zone: string;
    wasteType: string;
    description: string;
    priority: string;
  }) => void;
}

export function CreateTaskModal({ worker, workers, onClose, onCreate }: CreateTaskModalProps) {
  const [formData, setFormData] = useState({
    workerId: worker?.id || '',
    location: '',
    zone: worker?.zone || '',
    wasteType: 'General',
    description: '',
    priority: 'Medium'
  });

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    onCreate(formData);
  };

  const selectedWorker = workers.find(w => w.id === formData.workerId);

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/60 backdrop-blur-sm">
      <div className="bg-slate-900 border border-slate-800 rounded-2xl max-w-2xl w-full max-h-[90vh] overflow-y-auto">
        <div className="sticky top-0 bg-slate-900 border-b border-slate-800 px-6 py-4 flex items-center justify-between">
          <div>
            <h2 className="text-xl text-white">Create New Cleaning Task</h2>
            <p className="text-sm text-slate-400 mt-1">Assign a new cleanup task to a worker</p>
          </div>
          <button
            onClick={onClose}
            className="p-2 text-slate-400 hover:text-white hover:bg-slate-800 rounded-lg transition-all"
          >
            <X className="w-5 h-5" />
          </button>
        </div>

        <form onSubmit={handleSubmit} className="p-6 space-y-5">
          {/* Worker Selection */}
          <div>
            <label className="block text-sm text-slate-400 mb-2">Assign to Worker *</label>
            <select
              value={formData.workerId}
              onChange={(e) => {
                const worker = workers.find(w => w.id === e.target.value);
                setFormData({ 
                  ...formData, 
                  workerId: e.target.value,
                  zone: worker?.zone || formData.zone
                });
              }}
              className="w-full px-4 py-3 bg-slate-800/50 border border-slate-700 rounded-xl text-white focus:outline-none focus:border-emerald-500 focus:ring-2 focus:ring-emerald-500/20 appearance-none cursor-pointer"
              required
            >
              <option value="">Select a worker</option>
              {workers.filter(w => w.active).map(w => (
                <option key={w.id} value={w.id}>
                  {w.name} - {w.zone}
                </option>
              ))}
            </select>
            {selectedWorker && (
              <p className="text-xs text-slate-500 mt-2">
                Assigned Zone: {selectedWorker.zone}
              </p>
            )}
          </div>

          {/* Location */}
          <div>
            <label className="block text-sm text-slate-400 mb-2">Location *</label>
            <div className="relative">
              <MapPin className="absolute left-3 top-1/2 -translate-y-1/2 w-5 h-5 text-slate-400" />
              <input
                type="text"
                value={formData.location}
                onChange={(e) => setFormData({ ...formData, location: e.target.value })}
                className="w-full pl-10 pr-4 py-3 bg-slate-800/50 border border-slate-700 rounded-xl text-white placeholder-slate-500 focus:outline-none focus:border-emerald-500 focus:ring-2 focus:ring-emerald-500/20 transition-all"
                placeholder="e.g., Main Street, Central Park"
                required
              />
            </div>
          </div>

          {/* Zone */}
          <div>
            <label className="block text-sm text-slate-400 mb-2">Zone *</label>
            <select
              value={formData.zone}
              onChange={(e) => setFormData({ ...formData, zone: e.target.value })}
              className="w-full px-4 py-3 bg-slate-800/50 border border-slate-700 rounded-xl text-white focus:outline-none focus:border-emerald-500 focus:ring-2 focus:ring-emerald-500/20 appearance-none cursor-pointer"
              required
            >
              <option value="">Select Zone</option>
              <option value="North District">North District</option>
              <option value="South District">South District</option>
              <option value="East District">East District</option>
              <option value="West District">West District</option>
              <option value="Central">Central</option>
            </select>
          </div>

          {/* Waste Type */}
          <div>
            <label className="block text-sm text-slate-400 mb-2">Waste Type *</label>
            <select
              value={formData.wasteType}
              onChange={(e) => setFormData({ ...formData, wasteType: e.target.value })}
              className="w-full px-4 py-3 bg-slate-800/50 border border-slate-700 rounded-xl text-white focus:outline-none focus:border-emerald-500 focus:ring-2 focus:ring-emerald-500/20 appearance-none cursor-pointer"
              required
            >
              <option value="General">General Waste</option>
              <option value="Organic">Organic Waste</option>
              <option value="Recyclable">Recyclable Materials</option>
              <option value="Hazardous">Hazardous Waste</option>
            </select>
          </div>

          {/* Priority */}
          <div>
            <label className="block text-sm text-slate-400 mb-2">Priority Level *</label>
            <div className="grid grid-cols-3 gap-3">
              {['Low', 'Medium', 'High'].map((priority) => (
                <button
                  key={priority}
                  type="button"
                  onClick={() => setFormData({ ...formData, priority })}
                  className={`px-4 py-3 rounded-xl border transition-all ${
                    formData.priority === priority
                      ? priority === 'High'
                        ? 'bg-red-500/20 border-red-500/30 text-red-500'
                        : priority === 'Medium'
                        ? 'bg-yellow-500/20 border-yellow-500/30 text-yellow-500'
                        : 'bg-green-500/20 border-green-500/30 text-green-500'
                      : 'bg-slate-800/50 border-slate-700 text-slate-400 hover:border-slate-600'
                  }`}
                >
                  {priority}
                </button>
              ))}
            </div>
          </div>

          {/* Description */}
          <div>
            <label className="block text-sm text-slate-400 mb-2">Task Description *</label>
            <textarea
              value={formData.description}
              onChange={(e) => setFormData({ ...formData, description: e.target.value })}
              rows={4}
              className="w-full px-4 py-3 bg-slate-800/50 border border-slate-700 rounded-xl text-white placeholder-slate-500 focus:outline-none focus:border-emerald-500 focus:ring-2 focus:ring-emerald-500/20 transition-all resize-none"
              placeholder="Describe the cleanup task in detail..."
              required
            />
          </div>

          {/* Warning for Hazardous */}
          {formData.wasteType === 'Hazardous' && (
            <div className="bg-red-500/10 border border-red-500/20 rounded-xl p-4 flex items-start gap-3">
              <AlertTriangle className="w-5 h-5 text-red-500 flex-shrink-0 mt-0.5" />
              <div>
                <p className="text-sm text-red-500">Hazardous Waste Task</p>
                <p className="text-xs text-slate-400 mt-1">
                  Ensure the assigned worker has proper safety equipment and training for handling hazardous materials.
                </p>
              </div>
            </div>
          )}

          {/* Action Buttons */}
          <div className="flex gap-3 pt-4 border-t border-slate-800">
            <button
              type="button"
              onClick={onClose}
              className="flex-1 px-4 py-3 bg-slate-800 hover:bg-slate-700 text-white rounded-xl transition-all"
            >
              Cancel
            </button>
            <button
              type="submit"
              className="flex-1 px-4 py-3 bg-gradient-to-r from-emerald-500 to-teal-600 text-white rounded-xl hover:shadow-xl hover:shadow-emerald-500/30 transition-all duration-300"
            >
              Create Task
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}
