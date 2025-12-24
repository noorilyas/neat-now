import React, { useState } from 'react';
import { X } from 'lucide-react';

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
}

interface WorkerModalProps {
  worker: Worker | null;
  onClose: () => void;
  onSave: (worker: Partial<Worker>) => void;
}

export function WorkerModal({ worker, onClose, onSave }: WorkerModalProps) {
  const [formData, setFormData] = useState({
    name: worker?.name || '',
    email: worker?.email || '',
    phone: worker?.phone || '',
    zone: worker?.zone || ''
  });

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    onSave(formData);
  };

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/60 backdrop-blur-sm">
      <div className="bg-slate-900 border border-slate-800 rounded-2xl max-w-md w-full">
        <div className="border-b border-slate-800 px-6 py-4 flex items-center justify-between">
          <h2 className="text-xl text-white">{worker ? 'Edit Worker' : 'Add New Worker'}</h2>
          <button
            onClick={onClose}
            className="p-2 text-slate-400 hover:text-white hover:bg-slate-800 rounded-lg transition-all"
          >
            <X className="w-5 h-5" />
          </button>
        </div>

        <form onSubmit={handleSubmit} className="p-6 space-y-4">
          <div>
            <label className="block text-sm text-slate-400 mb-2">Full Name *</label>
            <input
              type="text"
              value={formData.name}
              onChange={(e) => setFormData({ ...formData, name: e.target.value })}
              className="w-full px-4 py-3 bg-slate-800/50 border border-slate-700 rounded-xl text-white placeholder-slate-500 focus:outline-none focus:border-emerald-500 focus:ring-2 focus:ring-emerald-500/20 transition-all"
              placeholder="Enter worker's full name"
              required
            />
          </div>

          <div>
            <label className="block text-sm text-slate-400 mb-2">Email Address *</label>
            <input
              type="email"
              value={formData.email}
              onChange={(e) => setFormData({ ...formData, email: e.target.value })}
              className="w-full px-4 py-3 bg-slate-800/50 border border-slate-700 rounded-xl text-white placeholder-slate-500 focus:outline-none focus:border-emerald-500 focus:ring-2 focus:ring-emerald-500/20 transition-all"
              placeholder="worker@cleanup.gov"
              required
            />
          </div>

          <div>
            <label className="block text-sm text-slate-400 mb-2">Phone Number *</label>
            <input
              type="tel"
              value={formData.phone}
              onChange={(e) => setFormData({ ...formData, phone: e.target.value })}
              className="w-full px-4 py-3 bg-slate-800/50 border border-slate-700 rounded-xl text-white placeholder-slate-500 focus:outline-none focus:border-emerald-500 focus:ring-2 focus:ring-emerald-500/20 transition-all"
              placeholder="+1 555-0000"
              required
            />
          </div>

          <div>
            <label className="block text-sm text-slate-400 mb-2">Assigned Zone *</label>
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

          <div className="flex gap-3 pt-4">
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
              {worker ? 'Update Worker' : 'Create Worker'}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}
