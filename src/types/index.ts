// Types
export type ReportStatus = 'Pending' | 'Assigned' | 'Resolved' | 'Overdue';
export type WasteType = 'Organic' | 'Recyclable' | 'Hazardous' | 'General';
export type UserRole = 'Admin' | 'Worker' | 'Citizen';

export interface Report {
  id: string;
  citizenName: string;
  citizenId: string;
  workerName?: string;
  workerId?: string;
  location: string;
  zone: string;
  status: ReportStatus;
  submittedAt: Date;
  assignedAt?: Date;
  resolvedAt?: Date;
  wasteType: WasteType;
  aiVerification: {
    verified: boolean;
    confidence: number;
    classification: WasteType;
  };
  description: string;
  beforeImage: string;
  afterImage?: string;
  urgency: number;
  lat: number;
  lng: number;
}

export interface Worker {
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

export interface User {
  id: string;
  name: string;
  role: UserRole;
  email: string;
}

export interface Activity {
  id: string;
  type: 'new_report' | 'resolved' | 'assigned' | 'alert';
  message: string;
  timestamp: Date;
  reportId?: string;
}
