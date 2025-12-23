from rest_framework import status, generics, permissions
from rest_framework.decorators import api_view, permission_classes
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from .models import Report
from .serializers import (
    ReportCreateSerializer,
    ReportListSerializer,
    ReportDetailSerializer,
    ReportUpdateSerializer
)
from accounts.models import Account


@api_view(['POST'])
@permission_classes([IsAuthenticated])
def create_report_view(request):
    """
    Create new waste report
    POST /api/reports/create/
    
    Body (multipart/form-data):
    {
        "image_before": <file>,
        "source": "camera" | "gallery",
        "latitude": <decimal> (required if source=camera),
        "longitude": <decimal> (required if source=camera)
    }
    
    Rules:
    - If source="camera": GPS coordinates are required (auto-attached)
    - If source="gallery": GPS coordinates are optional (can be set manually via map)
    """
    serializer = ReportCreateSerializer(data=request.data, context={'request': request})
    
    if serializer.is_valid():
        report = serializer.save()
        
        return Response(
            {
                'message': 'Report submitted successfully.',
                'report_id': report.report_id,
                'status': report.status,
                'ai_result': report.ai_result,
                'has_gps': report.has_gps_coordinates,
            },
            status=status.HTTP_201_CREATED
        )
    
    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


class ReportListView(generics.ListAPIView):
    """
    List reports for authenticated user
    GET /api/reports/
    
    - Citizens see only their own reports
    - Workers see assigned reports
    - Admins see all reports
    """
    permission_classes = [IsAuthenticated]
    serializer_class = ReportListSerializer
    
    def get_queryset(self):
        user = self.request.user
        
        # Citizens see only their own reports
        if user.role == 'Citizen':
            return Report.objects.filter(citizen=user)
        
        # Workers see assigned reports
        elif user.role == 'Worker':
            return Report.objects.filter(worker=user)
        
        # Admins see all reports (if admin role exists)
        else:
            return Report.objects.all()


class ReportDetailView(generics.RetrieveAPIView):
    """
    Get report details
    GET /api/reports/<report_id>/
    """
    permission_classes = [IsAuthenticated]
    serializer_class = ReportDetailSerializer
    lookup_field = 'report_id'
    
    def get_queryset(self):
        user = self.request.user
        
        # Citizens see only their own reports
        if user.role == 'Citizen':
            return Report.objects.filter(citizen=user)
        
        # Workers see assigned reports
        elif user.role == 'Worker':
            return Report.objects.filter(worker=user)
        
        # Admins see all reports
        else:
            return Report.objects.all()


class ReportUpdateView(generics.UpdateAPIView):
    """
    Update report (for workers/admin)
    PATCH /api/reports/<report_id>/update/
    
    Body:
    {
        "status": "Assigned" | "Resolved" | "Rejected",
        "ai_result": "Waste" | "No Waste",
        "waste_type": "<any type detected by AI>",  # AI will detect and set this
        "ai_confidence": 0.85,
        "image_after": <file>,
    }
    """
    permission_classes = [IsAuthenticated]
    serializer_class = ReportUpdateSerializer
    lookup_field = 'report_id'
    
    def get_queryset(self):
        user = self.request.user
        
        # Only workers and admins can update reports
        if user.role == 'Worker':
            return Report.objects.filter(worker=user)
        elif user.role == 'Citizen':
            # Citizens cannot update reports
            return Report.objects.none()
        else:
            # Admins can update all reports
            return Report.objects.all()
    
    def update(self, request, *args, **kwargs):
        partial = kwargs.pop('partial', True)
        instance = self.get_object()
        serializer = self.get_serializer(instance, data=request.data, partial=partial)
        
        if serializer.is_valid():
            self.perform_update(serializer)
            return Response(
                {
                    'message': 'Report updated successfully.',
                    'report_id': instance.report_id,
                    'status': instance.status,
                },
                status=status.HTTP_200_OK
            )
        
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
