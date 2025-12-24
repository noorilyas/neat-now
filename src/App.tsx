import { useState, useEffect, useMemo } from 'react';
import { 
  LayoutDashboard, 
  FileText, 
  Map, 
  Users, 
  LogOut, 
  Bell, 
  Activity
} from 'lucide-react';
import { Workers } from './pages/Workers';
import { WorkerProfile } from './pages/WorkerProfile';
import { WorkerModal } from './components/WorkerModal';
import { CreateTaskModal } from './components/CreateTaskModal';
import { LoginScreen } from './pages/LoginScreen';
import { DashboardView } from './pages/DashboardView';
import { ReportsView } from './pages/ReportsView';
import { MapView } from './pages/MapView';
import { ReportDetailModal } from './components/ReportDetailModal';
import { CitizensModal } from './components/CitizensModal';
import { generateMockReports, generateMockWorkers } from './data/mockData';
import { Report, Worker, User, Activity as ActivityType, ReportStatus, WasteType } from './types';

// Main App Component
export default function App() {
  const [currentUser, setCurrentUser] = useState<User | null>(null);
  const [activeTab, setActiveTab] = useState<'dashboard' | 'reports' | 'map' | 'workers'>('dashboard');
  const [reports, setReports] = useState<Report[]>([]);
  const [workers, setWorkers] = useState<Worker[]>([]);
  const [activities, setActivities] = useState<ActivityType[]>([]);
  const [selectedReport, setSelectedReport] = useState<Report | null>(null);
  const [showWorkerModal, setShowWorkerModal] = useState(false);
  const [editingWorker, setEditingWorker] = useState<Worker | null>(null);
  const [selectedWorkerId, setSelectedWorkerId] = useState<string | null>(null);
  const [showCreateTaskModal, setShowCreateTaskModal] = useState(false);
  const [taskWorkerId, setTaskWorkerId] = useState<string | null>(null);
  const [showCitizensModal, setShowCitizensModal] = useState(false);
  const [sortWorkersByRating, setSortWorkersByRating] = useState(false);
  
  // Filters
  const [statusFilter, setStatusFilter] = useState<ReportStatus | 'All'>('All');
  const [workerFilter, setWorkerFilter] = useState<string>('All');
  const [zoneFilter, setZoneFilter] = useState<string>('All');
  const [wasteTypeFilter, setWasteTypeFilter] = useState<WasteType | 'All'>('All');
  const [searchQuery, setSearchQuery] = useState('');
  const [dateRange, setDateRange] = useState<{ start: string; end: string }>({ start: '', end: '' });
  
  // Initialize data
  useEffect(() => {
    const mockReports = generateMockReports();
    const mockWorkers = generateMockWorkers();
    setReports(mockReports);
    setWorkers(mockWorkers);
    
    // Generate activities
    const recentActivities: ActivityType[] = mockReports.slice(0, 8).map((r, i) => ({
      id: `ACT-${i}`,
      type: r.status === 'Resolved' ? 'resolved' : r.status === 'Assigned' ? 'assigned' : 'new_report',
      message: r.status === 'Resolved' 
        ? `Report ${r.id} resolved by ${r.workerName}` 
        : r.status === 'Assigned'
        ? `Report ${r.id} assigned to ${r.workerName}`
        : `New report ${r.id} submitted in ${r.zone}`,
      timestamp: r.submittedAt,
      reportId: r.id
    }));
    setActivities(recentActivities);
    
    // Simulate real-time updates
    const interval = setInterval(() => {
      setReports(prev => {
        const updated = [...prev];
        const randomIndex = Math.floor(Math.random() * updated.length);
        if (updated[randomIndex].status === 'Pending') {
          updated[randomIndex] = {
            ...updated[randomIndex],
            status: 'Assigned',
            workerName: mockWorkers[Math.floor(Math.random() * mockWorkers.length)].name,
            assignedAt: new Date()
          };
        }
        return updated;
      });
    }, 10000);
    
    return () => clearInterval(interval);
  }, []);
  
  // Login handler
  const handleLogin = (email: string, password: string) => {
    // Simulated login - in production, this would validate against backend
    setCurrentUser({
      id: 'USR-ADMIN-001',
      name: 'Admin User',
      role: 'Admin',
      email: email
    });
  };
  
  // Logout handler
  const handleLogout = () => {
    setCurrentUser(null);
    setActiveTab('dashboard');
  };
  
  // Filter reports
  const filteredReports = useMemo(() => {
    return reports.filter(report => {
      if (statusFilter !== 'All' && report.status !== statusFilter) return false;
      if (workerFilter !== 'All' && report.workerName !== workerFilter) return false;
      if (zoneFilter !== 'All' && report.zone !== zoneFilter) return false;
      if (wasteTypeFilter !== 'All' && report.wasteType !== wasteTypeFilter) return false;
      if (searchQuery && !report.id.toLowerCase().includes(searchQuery.toLowerCase()) && 
          !report.location.toLowerCase().includes(searchQuery.toLowerCase())) return false;
      if (dateRange.start && report.submittedAt < new Date(dateRange.start)) return false;
      if (dateRange.end && report.submittedAt > new Date(dateRange.end)) return false;
      return true;
    }).sort((a, b) => {
      // Sort by urgency (time pending)
      const aUrgency = a.status === 'Pending' || a.status === 'Overdue' 
        ? Date.now() - a.submittedAt.getTime() 
        : 0;
      const bUrgency = b.status === 'Pending' || b.status === 'Overdue' 
        ? Date.now() - b.submittedAt.getTime() 
        : 0;
      return bUrgency - aUrgency;
    });
  }, [reports, statusFilter, workerFilter, zoneFilter, wasteTypeFilter, searchQuery, dateRange]);
  
  // Stats calculations
  const stats = useMemo(() => {
    const total = reports.length;
    const pending = reports.filter(r => r.status === 'Pending').length;
    const assigned = reports.filter(r => r.status === 'Assigned').length;
    const resolved = reports.filter(r => r.status === 'Resolved').length;
    const overdue = reports.filter(r => r.status === 'Overdue').length;
    
    return { total, pending, assigned, resolved, overdue };
  }, [reports]);
  
  // Chart data
  const trendData = useMemo(() => {
    const last7Days = Array.from({ length: 7 }, (_, i) => {
      const date = new Date();
      date.setDate(date.getDate() - (6 - i));
      return {
        date: date.toLocaleDateString('en-US', { month: 'short', day: 'numeric' }),
        reports: Math.floor(Math.random() * 15) + 5,
        resolved: Math.floor(Math.random() * 10) + 3
      };
    });
    return last7Days;
  }, []);
  
  const statusDistribution = useMemo(() => [
    { name: 'Pending', value: stats.pending, color: '#ef4444' },
    { name: 'Assigned', value: stats.assigned, color: '#f59e0b' },
    { name: 'Resolved', value: stats.resolved, color: '#10b981' },
    { name: 'Overdue', value: stats.overdue, color: '#dc2626' }
  ], [stats]);
  
  // Top citizens and workers
  const topCitizens = useMemo(() => {
    const citizenReports = reports.reduce((acc, r) => {
      acc[r.citizenName] = (acc[r.citizenName] || 0) + 1;
      return acc;
    }, {} as Record<string, number>);
    
    return Object.entries(citizenReports)
      .sort((a, b) => b[1] - a[1])
      .slice(0, 5)
      .map(([name, count]) => ({ name, reports: count }));
  }, [reports]);
  
  const topWorkers = useMemo(() => {
    return [...workers]
      .sort((a, b) => b.tasksCompleted - a.tasksCompleted)
      .slice(0, 5);
  }, [workers]);
  
  // Task assignment
  const assignTask = (reportId: string, workerId: string) => {
    setReports(prev => prev.map(r => {
      if (r.id === reportId) {
        const worker = workers.find(w => w.id === workerId);
        return {
          ...r,
          workerId,
          workerName: worker?.name,
          status: 'Assigned' as ReportStatus,
          assignedAt: new Date()
        };
      }
      return r;
    }));
    
    setActivities(prev => [{
      id: `ACT-${Date.now()}`,
      type: 'assigned',
      message: `Report ${reportId} assigned to worker`,
      timestamp: new Date(),
      reportId
    }, ...prev.slice(0, 7)]);
  };
  
  // Override status
  const overrideStatus = (reportId: string, newStatus: ReportStatus) => {
    setReports(prev => prev.map(r => {
      if (r.id === reportId) {
        return {
          ...r,
          status: newStatus,
          resolvedAt: newStatus === 'Resolved' ? new Date() : undefined
        };
      }
      return r;
    }));
  };
  
  // Worker CRUD
  const saveWorker = (worker: Partial<Worker>) => {
    if (editingWorker) {
      setWorkers(prev => prev.map(w => w.id === editingWorker.id ? { ...w, ...worker } : w));
    } else {
      const newWorker: Worker = {
        id: `WKR-${String(workers.length + 1).padStart(4, '0')}`,
        name: worker.name || '',
        email: worker.email || '',
        phone: worker.phone || '',
        zone: worker.zone || '',
        tasksCompleted: 0,
        avgCompletionTime: 0,
        rating: 5.0,
        active: true
      };
      setWorkers(prev => [...prev, newWorker]);
    }
    setShowWorkerModal(false);
    setEditingWorker(null);
  };
  
  const deleteWorker = (workerId: string) => {
    setWorkers(prev => prev.filter(w => w.id !== workerId));
  };
  
  const toggleWorkerStatus = (workerId: string) => {
    setWorkers(prev => prev.map(w => w.id === workerId ? { ...w, active: !w.active } : w));
  };
  
  // Worker profile handlers
  const handleViewProfile = (workerId: string) => {
    setSelectedWorkerId(workerId);
  };
  
  const handleBackToWorkers = () => {
    setSelectedWorkerId(null);
  };
  
  const handlePasswordReset = (workerId: string) => {
    alert(`Password reset link sent to worker ${workerId}`);
  };
  
  // Task creation handlers
  const handleCreateTask = (workerId: string) => {
    setTaskWorkerId(workerId);
    setShowCreateTaskModal(true);
  };
  
  const handleTaskCreation = (task: any) => {
    // Create new report from task
    const newReport: Report = {
      id: `RPT-${String(reports.length + 1001).padStart(6, '0')}`,
      citizenName: 'Admin Created',
      citizenId: 'ADMIN',
      workerName: workers.find(w => w.id === task.workerId)?.name,
      workerId: task.workerId,
      location: task.location,
      zone: task.zone,
      status: 'Assigned',
      submittedAt: new Date(),
      assignedAt: new Date(),
      wasteType: task.wasteType as WasteType,
      aiVerification: {
        verified: true,
        confidence: 100,
        classification: task.wasteType as WasteType
      },
      description: task.description,
      beforeImage: 'https://images.unsplash.com/photo-1532996122724-e3c354a0b15b?w=400',
      urgency: task.priority === 'High' ? 9 : task.priority === 'Medium' ? 5 : 3,
      lat: 40.7128,
      lng: -74.0060
    };
    
    setReports(prev => [newReport, ...prev]);
    setShowCreateTaskModal(false);
    setTaskWorkerId(null);
    
    // Add activity
    setActivities(prev => [{
      id: `ACT-${Date.now()}`,
      type: 'assigned',
      message: `Task ${newReport.id} created and assigned to ${newReport.workerName}`,
      timestamp: new Date(),
      reportId: newReport.id
    }, ...prev.slice(0, 7)]);
  };
  
  // Login Screen
  if (!currentUser) {
    return <LoginScreen onLogin={handleLogin} />;
  }
  
  return (
    <div className="min-h-screen bg-gradient-to-br from-slate-950 via-slate-900 to-slate-950">
      {/* Header */}
      <header className="bg-slate-900/80 backdrop-blur-xl border-b border-slate-800 sticky top-0 z-50">
        <div className="max-w-[1920px] mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex items-center justify-between h-16">
            <div className="flex items-center gap-3">
              <div className="w-10 h-10 rounded-lg bg-gradient-to-br from-emerald-500 to-teal-600 flex items-center justify-center">
                <Activity className="w-6 h-6 text-white" />
              </div>
              <div>
                <h1 className="text-white">Neat Now </h1>
                <p className="text-xs text-slate-400">Admin Control Panel</p>
              </div>
            </div>
            
            <div className="flex items-center gap-4">
              <button className="relative p-2 text-slate-400 hover:text-white hover:bg-slate-800 rounded-lg transition-all">
                <Bell className="w-5 h-5" />
                <span className="absolute top-1 right-1 w-2 h-2 bg-red-500 rounded-full"></span>
              </button>
              
              <div className="flex items-center gap-3 px-4 py-2 bg-slate-800/50 rounded-lg border border-slate-700">
                <div className="text-right">
                  <p className="text-sm text-white">{currentUser.name}</p>
                  <p className="text-xs text-slate-400">User ID: {currentUser.id}</p>
                </div>
                <button
                  onClick={handleLogout}
                  className="p-2 text-slate-400 hover:text-red-400 hover:bg-slate-800 rounded-lg transition-all"
                >
                  <LogOut className="w-4 h-4" />
                </button>
              </div>
            </div>
          </div>
        </div>
      </header>
      
      {/* Navigation */}
      <nav className="bg-slate-900/50 backdrop-blur-sm border-b border-slate-800">
        <div className="max-w-[1920px] mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex gap-1 py-2">
            {[
              { id: 'dashboard', label: 'Dashboard', icon: LayoutDashboard },
              { id: 'reports', label: 'Reports', icon: FileText },
              { id: 'map', label: 'Map & Analytics', icon: Map },
              { id: 'workers', label: 'Workers', icon: Users }
            ].map(tab => (
              <button
                key={tab.id}
                onClick={() => setActiveTab(tab.id as any)}
                className={`flex items-center gap-2 px-4 py-2 rounded-lg transition-all ${
                  activeTab === tab.id
                    ? 'bg-emerald-500 text-white shadow-lg shadow-emerald-500/20'
                    : 'text-slate-400 hover:text-white hover:bg-slate-800'
                }`}
              >
                <tab.icon className="w-4 h-4" />
                <span className="hidden sm:inline">{tab.label}</span>
              </button>
            ))}
          </div>
        </div>
      </nav>
      
      {/* Main Content */}
      <main className="max-w-[1920px] mx-auto px-4 sm:px-6 lg:px-8 py-6">
        {activeTab === 'dashboard' && (
          <DashboardView 
            stats={stats}
            activities={activities}
            topCitizens={topCitizens}
            topWorkers={topWorkers}
            trendData={trendData}
            statusDistribution={statusDistribution}
            reports={reports}
            onNavigateToWorkers={() => {
              setActiveTab('workers');
              setSortWorkersByRating(true);
            }}
            onViewAllCitizens={() => setShowCitizensModal(true)}
          />
        )}
        
        {activeTab === 'reports' && (
          <ReportsView
            reports={filteredReports}
            workers={workers}
            statusFilter={statusFilter}
            setStatusFilter={setStatusFilter}
            workerFilter={workerFilter}
            setWorkerFilter={setWorkerFilter}
            zoneFilter={zoneFilter}
            setZoneFilter={setZoneFilter}
            wasteTypeFilter={wasteTypeFilter}
            setWasteTypeFilter={setWasteTypeFilter}
            searchQuery={searchQuery}
            setSearchQuery={setSearchQuery}
            dateRange={dateRange}
            setDateRange={setDateRange}
            onSelectReport={setSelectedReport}
          />
        )}
        
        {activeTab === 'map' && (
          <MapView reports={reports} trendData={trendData} />
        )}
        
        {activeTab === 'workers' && !selectedWorkerId && (
          <Workers
            workers={workers}
            onViewProfile={handleViewProfile}
            onEdit={(worker) => {
              setEditingWorker(worker);
              setShowWorkerModal(true);
            }}
            onDelete={deleteWorker}
            onToggleStatus={toggleWorkerStatus}
            onAddNew={() => {
              setEditingWorker(null);
              setShowWorkerModal(true);
            }}
            onCreateTask={handleCreateTask}
            sortByRating={sortWorkersByRating}
          />
        )}
        
        {activeTab === 'workers' && selectedWorkerId && (
          <WorkerProfile
            worker={workers.find(w => w.id === selectedWorkerId)!}
            currentAssignments={reports.filter(r => r.workerId === selectedWorkerId && r.status !== 'Resolved')}
            activityLog={activities.filter(a => a.reportId && reports.find(r => r.id === a.reportId && r.workerId === selectedWorkerId)).slice(0, 10).map(a => ({
              id: a.id,
              action: a.message,
              timestamp: a.timestamp,
              reportId: a.reportId
            }))}
            onBack={handleBackToWorkers}
            onPasswordReset={handlePasswordReset}
          />
        )}
      </main>
      
      {/* Report Detail Modal */}
      {selectedReport && (
        <ReportDetailModal
          report={selectedReport}
          workers={workers}
          onClose={() => setSelectedReport(null)}
          onAssign={assignTask}
          onOverrideStatus={overrideStatus}
        />
      )}
      
      {/* Worker Modal */}
      {showWorkerModal && (
        <WorkerModal
          worker={editingWorker}
          onClose={() => {
            setShowWorkerModal(false);
            setEditingWorker(null);
          }}
          onSave={saveWorker}
        />
      )}
      
      {/* Create Task Modal */}
      {showCreateTaskModal && (
        <CreateTaskModal
          worker={workers.find(w => w.id === taskWorkerId) || null}
          workers={workers.filter(w => w.active)}
          onClose={() => {
            setShowCreateTaskModal(false);
            setTaskWorkerId(null);
          }}
          onCreate={handleTaskCreation}
        />
      )}
      
      {/* Citizens Modal */}
      {showCitizensModal && (
        <CitizensModal
          onClose={() => setShowCitizensModal(false)}
          reports={reports}
        />
      )}
    </div>
  );
}