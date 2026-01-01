# Worker-User Connection Architecture

## Overview
Yeh document worker aur user ke beech connection, assignment, aur rating system ka complete architecture explain karta hai.

---

## 1. Report Assignment Flow

### Option A: Manual Assignment (Worker Accepts)
```
User submits report → Status: "Pending"
                    ↓
Worker sees available reports → Worker accepts → Status: "Assigned"
                    ↓
User gets notification: "Your report has been assigned to [Worker Name]"
```

### Option B: Auto-Assignment (System Assigns)
```
User submits report → Status: "Pending"
                    ↓
System finds nearest/available worker → Auto-assign → Status: "Assigned"
                    ↓
Worker gets notification: "New report assigned to you"
User gets notification: "Your report has been assigned to [Worker Name]"
```

### Option C: Hybrid (Recommended)
```
User submits report → Status: "Pending"
                    ↓
System sends notification to nearby workers (within 5km radius)
                    ↓
Multiple workers see the report → First worker to accept gets it
                    ↓
Status: "Assigned" → Other workers see "Already Assigned"
```

---

## 2. Database Models (New Tables Needed)

### A. WorkerRating Model
```python
class WorkerRating(models.Model):
    rating_id = models.BigAutoField(primary_key=True)
    
    # Foreign keys
    report = models.ForeignKey(
        Report,
        on_delete=models.CASCADE,
        related_name='ratings',
        unique=True  # One rating per report
    )
    citizen = models.ForeignKey(
        Account,
        on_delete=models.CASCADE,
        related_name='given_ratings',
        limit_choices_to={'role': 'Citizen'}
    )
    worker = models.ForeignKey(
        Account,
        on_delete=models.CASCADE,
        related_name='received_ratings',
        limit_choices_to={'role': 'Worker'}
    )
    
    # Rating fields
    rating = models.IntegerField(
        validators=[MinValueValidator(1), MaxValueValidator(5)],
        help_text='1-5 star rating'
    )
    comment = models.TextField(
        max_length=500,
        null=True,
        blank=True,
        help_text='Optional feedback comment'
    )
    
    # Timestamps
    created_at = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        db_table = 'worker_ratings'
        unique_together = ['report', 'citizen']  # One rating per report per citizen
```

### B. ReportAssignment Model (Optional - for tracking assignment history)
```python
class ReportAssignment(models.Model):
    assignment_id = models.BigAutoField(primary_key=True)
    
    report = models.ForeignKey(
        Report,
        on_delete=models.CASCADE,
        related_name='assignments'
    )
    worker = models.ForeignKey(
        Account,
        on_delete=models.CASCADE,
        related_name='assignments',
        limit_choices_to={'role': 'Worker'}
    )
    
    # Assignment type
    ASSIGNMENT_TYPE_CHOICES = [
        ('auto', 'Auto-Assigned'),
        ('manual', 'Worker Accepted'),
        ('admin', 'Admin Assigned'),
    ]
    assignment_type = models.CharField(
        max_length=10,
        choices=ASSIGNMENT_TYPE_CHOICES,
        default='manual'
    )
    
    # Timestamps
    assigned_at = models.DateTimeField(auto_now_add=True)
    accepted_at = models.DateTimeField(null=True, blank=True)
```

### C. Notification Model (for push notifications)
```python
class Notification(models.Model):
    notification_id = models.BigAutoField(primary_key=True)
    
    # Foreign keys
    user = models.ForeignKey(
        Account,
        on_delete=models.CASCADE,
        related_name='notifications'
    )
    report = models.ForeignKey(
        Report,
        on_delete=models.CASCADE,
        related_name='notifications',
        null=True,
        blank=True
    )
    
    # Notification fields
    NOTIFICATION_TYPE_CHOICES = [
        ('report_assigned', 'Report Assigned'),
        ('report_accepted', 'Report Accepted'),
        ('report_resolved', 'Report Resolved'),
        ('rating_received', 'Rating Received'),
        ('new_report_available', 'New Report Available'),
    ]
    notification_type = models.CharField(
        max_length=30,
        choices=NOTIFICATION_TYPE_CHOICES
    )
    title = models.CharField(max_length=255)
    message = models.TextField()
    is_read = models.BooleanField(default=False)
    
    # Timestamps
    created_at = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        db_table = 'notifications'
        ordering = ['-created_at']
```

---

## 3. API Endpoints (New)

### A. Worker Assignment Endpoints

#### 1. Get Available Reports (for Workers)
```
GET /api/reports/available/
```
- Returns all "Pending" reports within worker's radius
- Sorted by distance (nearest first)
- Excludes already assigned reports

#### 2. Accept Report (Worker accepts a report)
```
POST /api/reports/{report_id}/accept/
```
- Worker accepts a pending report
- Changes status: "Pending" → "Assigned"
- Sets worker field
- Creates notification for user
- Returns success message

#### 3. Reject Report (Worker rejects)
```
POST /api/reports/{report_id}/reject/
```
- Worker rejects a report (optional)
- Report remains "Pending" for other workers

### B. Rating Endpoints

#### 1. Rate Worker (User rates worker after report resolved)
```
POST /api/ratings/
Body: {
    "report_id": 123,
    "rating": 5,
    "comment": "Great work! Very fast response."
}
```
- Creates WorkerRating
- Updates worker's average rating
- Creates notification for worker

#### 2. Get Worker Ratings
```
GET /api/workers/{worker_id}/ratings/
```
- Returns all ratings for a worker
- Includes average rating, total ratings count

#### 3. Get Rating for Report
```
GET /api/reports/{report_id}/rating/
```
- Returns rating if user has rated this report

### C. Notification Endpoints

#### 1. Get Notifications
```
GET /api/notifications/
Query params: ?unread_only=true
```
- Returns user's notifications
- Can filter unread only

#### 2. Mark Notification as Read
```
PATCH /api/notifications/{notification_id}/read/
```

#### 3. Mark All as Read
```
POST /api/notifications/mark-all-read/
```

---

## 4. Backend Logic Flow

### A. Report Submission (User)
```python
# reports/views.py
@api_view(['POST'])
def create_report_view(request):
    # ... existing code ...
    
    report = Report.objects.create(
        citizen=request.user,
        status='Pending',
        # ... other fields ...
    )
    
    # Find nearby workers (within 5km radius)
    nearby_workers = find_nearby_workers(
        latitude=report.latitude,
        longitude=report.longitude,
        radius_km=5
    )
    
    # Send notifications to nearby workers
    for worker in nearby_workers:
        Notification.objects.create(
            user=worker,
            report=report,
            notification_type='new_report_available',
            title='New Report Available',
            message=f'New waste report available near you. Distance: {distance}km'
        )
    
    # Send push notification (if implemented)
    send_push_notifications(nearby_workers, report)
    
    return Response(...)
```

### B. Worker Accepts Report
```python
@api_view(['POST'])
@permission_classes([IsAuthenticated])
def accept_report_view(request, report_id):
    if request.user.role != 'Worker':
        return Response({'error': 'Only workers can accept reports'}, status=403)
    
    try:
        report = Report.objects.get(
            report_id=report_id,
            status='Pending',
            worker__isnull=True  # Not already assigned
        )
    except Report.DoesNotExist:
        return Response({'error': 'Report not available'}, status=404)
    
    # Assign to worker
    report.worker = request.user
    report.status = 'Assigned'
    report.save()
    
    # Create notification for user
    Notification.objects.create(
        user=report.citizen,
        report=report,
        notification_type='report_assigned',
        title='Report Assigned',
        message=f'Your report #{report.report_id} has been assigned to {request.user.name}'
    )
    
    # Send push notification to user
    send_push_notification(report.citizen, notification)
    
    return Response({
        'success': True,
        'message': 'Report accepted successfully',
        'report_id': report.report_id
    })
```

### C. User Rates Worker
```python
@api_view(['POST'])
@permission_classes([IsAuthenticated])
def rate_worker_view(request):
    if request.user.role != 'Citizen':
        return Response({'error': 'Only citizens can rate workers'}, status=403)
    
    serializer = WorkerRatingSerializer(data=request.data)
    if serializer.is_valid():
        report_id = serializer.validated_data['report_id']
        
        # Check if report is resolved and belongs to user
        try:
            report = Report.objects.get(
                report_id=report_id,
                citizen=request.user,
                status='Resolved',
                worker__isnull=False
            )
        except Report.DoesNotExist:
            return Response({'error': 'Report not found or not resolved'}, status=404)
        
        # Check if already rated
        if WorkerRating.objects.filter(report=report, citizen=request.user).exists():
            return Response({'error': 'Already rated this report'}, status=400)
        
        # Create rating
        rating = WorkerRating.objects.create(
            report=report,
            citizen=request.user,
            worker=report.worker,
            rating=serializer.validated_data['rating'],
            comment=serializer.validated_data.get('comment')
        )
        
        # Update worker's average rating
        update_worker_average_rating(report.worker)
        
        # Create notification for worker
        Notification.objects.create(
            user=report.worker,
            report=report,
            notification_type='rating_received',
            title='New Rating Received',
            message=f'You received a {rating.rating}-star rating from {request.user.name}'
        )
        
        return Response({
            'success': True,
            'message': 'Rating submitted successfully',
            'rating_id': rating.rating_id
        })
    
    return Response(serializer.errors, status=400)
```

### D. Helper Functions
```python
def find_nearby_workers(latitude, longitude, radius_km=5):
    """
    Find workers within radius using GPS coordinates
    """
    # This requires worker location tracking
    # For now, return all active workers
    # Later: Implement geolocation-based search
    return Account.objects.filter(
        role='Worker',
        email_verified=True
    )[:10]  # Limit to 10 workers

def update_worker_average_rating(worker):
    """
    Calculate and update worker's average rating
    """
    ratings = WorkerRating.objects.filter(worker=worker)
    if ratings.exists():
        avg_rating = ratings.aggregate(Avg('rating'))['rating__avg']
        # Store in Account model or separate WorkerProfile model
        # For now, calculate on-the-fly
    return avg_rating
```

---

## 5. Frontend Flow (Flutter)

### A. User Side

#### 1. Report Submission
```dart
// After report submission
- Show success dialog
- Report status: "Pending"
- Show message: "Waiting for worker assignment..."
```

#### 2. Report Assigned Notification
```dart
// When notification received
- Update report status: "Assigned"
- Show worker info: Name, Rating, Profile Image
- Display: "Assigned to [Worker Name] ⭐ 4.5"
```

#### 3. Rate Worker (After Report Resolved)
```dart
// In report detail page
- Show "Rate Worker" button (only if resolved and not rated)
- Open rating dialog:
  - Star rating (1-5)
  - Comment field (optional)
- Submit rating
- Show success message
- Update UI to show rating
```

### B. Worker Side

#### 1. Available Reports List
```dart
// Worker dashboard
- Show "Available Reports" tab
- List all "Pending" reports
- Show distance, waste type, image
- "Accept" button on each report
```

#### 2. Accept Report
```dart
// When worker clicks "Accept"
- Show confirmation dialog
- Call API: POST /api/reports/{id}/accept/
- On success:
  - Move report to "My Tasks" tab
  - Show notification: "Report accepted!"
  - Update report status to "Assigned"
```

#### 3. View Ratings
```dart
// Worker profile page
- Show average rating: ⭐ 4.5 (from 23 ratings)
- List of recent ratings with comments
- Rating breakdown (5 stars: 10, 4 stars: 8, etc.)
```

---

## 6. Database Migrations

### Create new models:
```bash
cd neat_now_backend
python manage.py makemigrations
python manage.py migrate
```

---

## 7. Implementation Priority

### Phase 1: Basic Assignment (Week 1)
1. ✅ Worker accepts report endpoint
2. ✅ Update report status to "Assigned"
3. ✅ Notification to user when assigned
4. ✅ Show worker info in user's report detail

### Phase 2: Rating System (Week 2)
1. ✅ WorkerRating model
2. ✅ Rate worker endpoint
3. ✅ Display ratings in worker profile
4. ✅ Calculate average rating

### Phase 3: Enhanced Features (Week 3)
1. ✅ Auto-assignment based on location
2. ✅ Push notifications
3. ✅ Rating breakdown charts
4. ✅ Worker performance metrics

---

## 8. Example API Responses

### Accept Report Response
```json
{
    "success": true,
    "message": "Report accepted successfully",
    "report_id": 123,
    "report": {
        "report_id": 123,
        "status": "Assigned",
        "worker": {
            "account_id": 5,
            "name": "Ahmed Worker",
            "email": "ahmed@worker.com",
            "profile_image": "https://..."
        },
        "citizen": {
            "account_id": 1,
            "name": "John Citizen"
        }
    }
}
```

### Rating Response
```json
{
    "success": true,
    "message": "Rating submitted successfully",
    "rating_id": 45,
    "rating": {
        "rating_id": 45,
        "rating": 5,
        "comment": "Great work!",
        "created_at": "2024-01-15T10:30:00Z"
    }
}
```

---

## 9. UI/UX Suggestions

### User Side:
- **Report Card**: Show worker avatar + name when assigned
- **Rating Dialog**: Beautiful star rating with animation
- **Notification Badge**: Show unread notifications count
- **Worker Profile Preview**: Tap to see worker's ratings and stats

### Worker Side:
- **Available Reports Map**: Show pending reports on map
- **Accept Button**: Prominent, with distance shown
- **My Tasks**: List of assigned reports
- **Rating Display**: Show average rating prominently in profile

---

## 10. Security Considerations

1. **Authorization**: Only workers can accept reports
2. **Validation**: User can only rate their own resolved reports
3. **Rate Limiting**: Prevent spam ratings
4. **Location Privacy**: Don't expose exact user location to workers

---

## Next Steps

1. Create WorkerRating model
2. Create Notification model
3. Implement accept report endpoint
4. Implement rate worker endpoint
5. Update frontend to show worker info
6. Add rating UI components



