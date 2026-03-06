from django.shortcuts import render
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from .serializer import UserSerializer, RegisterSerializer, LoginSerializer
from .models import USERS
from django.contrib.auth import authenticate
from .models import Token as CustomToken
from django.utils import timezone
import uuid

# Create your views here.
class RegisterView(APIView):
    def post(self, request):
        serializer = RegisterSerializer(data=request.data)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
    
class ConfirmEmailView(APIView):
    def get(self, request, token):
        try:
            user = USERS.objects.get(verification_token=token)
            user.verified_at = timezone.now()
            user.save()
            return Response({'message': 'Email confirmed successfully.'}, status=status.HTTP_200_OK)
        except USERS.DoesNotExist:
            return Response({'error': 'Invalid token.'}, status=status.HTTP_400_BAD_REQUEST)
        
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
                    else:
                        # Delete expired token
                        existing_token.delete()
                
                # Create new token
                token_value = str(uuid.uuid4())
                token = CustomToken.objects.create(
                    userID=user,
                    value=token_value,
                    end_at=timezone.now() + timezone.timedelta(days=7)  # Token valid for 7 days
                )
                return Response({'token': token.value}, status=status.HTTP_200_OK)
            return Response({'error': 'Invalid credentials.'}, status=status.HTTP_400_BAD_REQUEST)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)