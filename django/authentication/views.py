from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from rest_framework.permissions import IsAuthenticated
from .serializer import LoginSerializer,AdminSerializer,NormalUserSerializer
from .models import USERS
from django.contrib.auth import authenticate
from .models import Token as CustomToken
from .authentication import CustomTokenAuthentication
from django.utils import timezone
import uuid

# Create your views here.

class RegisterAdminView(APIView):
    def post(self, request):
        serializer = AdminSerializer(data=request.data)
        if serializer.is_valid():
            # Create user with is_staff=True
            user = USERS.objects.create_user(
                name=serializer.validated_data['name'],
                email=serializer.validated_data['email'],
                password=serializer.validated_data['password'],
                is_staff=True
            )
            return Response(AdminSerializer(user).data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
    
class RegisterNormalView(APIView):
    def post(self, request):
        serializer = NormalUserSerializer(data=request.data)
        if serializer.is_valid():
            # Create user with is_staff=False
            user = USERS.objects.create_user(
                name=serializer.validated_data['name'],
                email=serializer.validated_data['email'],
                password=serializer.validated_data['password'],
                is_staff=False
            )
            return Response(NormalUserSerializer(user).data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

class LoginView(APIView):
    def post(self, request):
        serializer = LoginSerializer(data=request.data)
        if serializer.is_valid():
            user = authenticate(email=serializer.validated_data['email'], password=serializer.validated_data['password'])
            if user is not None:
                # Check if token already exists for this user
                existing_token = CustomToken.objects.filter(userID=user).first()
                if existing_token:
                    # Check if token is still valid
                    if existing_token.end_at and existing_token.end_at > timezone.now():
                        return Response({'token': existing_token.value}, status=status.HTTP_200_OK)
                
                # Create new token
                token_value = str(uuid.uuid4())
                token = CustomToken.objects.create(
                    userID=user,
                    value=token_value,
                    end_at=timezone.now() + timezone.timedelta(days=7)  # Token valid for 7 days
                )
                return Response({'token': token.value}, status=status.HTTP_200_OK)
            return Response({'error': 'Invalid credentials.'}, status=status.HTTP_400_BAD_REQUEST)
        return Response({'error': serializer.errors}, status=status.HTTP_400_BAD_REQUEST)

class RenewTokenView(APIView):
    permission_classes = [IsAuthenticated]
    authentication_classes = [CustomTokenAuthentication]
    
    def post(self, request):
        # Get the current token from headers
        token_value = request.headers.get('Authorization', '').replace('Bearer ', '')
        
        if not token_value:
            return Response({'error': 'Token required.'}, status=status.HTTP_400_BAD_REQUEST)
        
        try:
            token = CustomToken.objects.get(value=token_value, userID=request.user)
            
            # Add 7 days to the current expiration (or from now if already expired)
            if token.end_at and token.end_at > timezone.now():
                # Token is valid - extend from current end_at
                token.end_at = token.end_at + timezone.timedelta(days=1)
            else:
                # Token is expired - set new expiration from now
                token.end_at = timezone.now() + timezone.timedelta(days=7)
            
            token.save()
            
            return Response({
                'message': 'Token extended successfully',
                'new_expiry': token.end_at
            }, status=status.HTTP_200_OK)
            
        except CustomToken.DoesNotExist:
            return Response({'error': 'Invalid token.'}, status=status.HTTP_400_BAD_REQUEST)

class LoginAdminView(APIView):
    def post(self, request):
        serializer = LoginSerializer(data=request.data)
        if serializer.is_valid():
            user = authenticate(email=serializer.validated_data['email'], password=serializer.validated_data['password'])
            if user is not None:

                if not user.is_staff:
                    return Response({'error': 'User is not an administrator.'}, status=status.HTTP_403_FORBIDDEN)
                
                # Check if token already exists for this user
                existing_token = CustomToken.objects.filter(userID=user).first()
                if existing_token:
                    # Check if token is still valid (within 7 days)
                    if existing_token.end_at and existing_token.end_at > timezone.now():
                        return Response({'token': existing_token.value}, status=status.HTTP_200_OK)
                    # Don't delete - just create a new token below
                
                # Create new token with 7 days validity
                token_value = str(uuid.uuid4())
                token = CustomToken.objects.create(
                    userID=user,
                    value=token_value,
                    end_at=timezone.now() + timezone.timedelta(days=7)  # Token valid for 7 days
                )
                return Response({'token': token.value}, status=status.HTTP_200_OK)
            return Response({'error': 'Invalid credentials.'}, status=status.HTTP_400_BAD_REQUEST)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

class LogoutView(APIView):
    permission_classes = [IsAuthenticated]
    authentication_classes = [CustomTokenAuthentication]
    
    def post(self, request):
        # Get the current token from headers
        token_value = request.headers.get('Authorization', '').replace('Bearer ', '')
        
        if not token_value:
            return Response({'error': 'Token required.'}, status=status.HTTP_400_BAD_REQUEST)
        
        try:
            token = CustomToken.objects.get(value=token_value, userID=request.user)
            token.delete()  # Invalidate the token by deleting it
            return Response({'message': 'Logged out successfully.'}, status=status.HTTP_200_OK)
        except CustomToken.DoesNotExist:
            return Response({'error': 'Invalid token.'}, status=status.HTTP_400_BAD_REQUEST)
