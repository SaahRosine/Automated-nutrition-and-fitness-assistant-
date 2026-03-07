from django.shortcuts import render
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from rest_framework.permissions import IsAuthenticated, IsAdminUser
from .serializer import UserSerializer, RegisterSerializer, LoginSerializer
from .models import USERS, InvitationCode
from django.contrib.auth import authenticate
from .models import Token as CustomToken
from .authentication import CustomTokenAuthentication
from django.utils import timezone
from django.core.mail import send_mail
from django.conf import settings
import uuid
import random
import string

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


def generate_invitation_code():
    """
    Generate an invitation code with 1 number + 5 random letters.
    Example: A3B7CD or 9XYZAB
    """
    # Generate 1 random digit
    number = random.randint(0, 9)
    # Generate 5 random uppercase letters
    letters = ''.join(random.choices(string.ascii_uppercase, k=5))
    # Combine: letter + number + 4 letters (to get total of 1 number + 5 letters)
    # Format: 1 number + 5 letters in random positions
    code = f"{random.choice(letters)}{number}{letters[:4]}"
    return code


class GenerateInvitationCodeView(APIView):
    permission_classes = [IsAuthenticated, IsAdminUser]
    
    def post(self, request):
        # Only admins can generate invitation codes
        if not request.user.is_staff:
            return Response(
                {'error': 'Only administrators can generate invitation codes.'},
                status=status.HTTP_403_FORBIDDEN
            )
        
        # Get email from request (optional - if not provided, code can be used for any email)
        guest_email = request.data.get('email', '')
        
        # Generate the invitation code (1 number + 5 letters)
        invitation_code = generate_invitation_code()
        
        # Create the invitation code record
        invite = InvitationCode.objects.create(
            guestEmail=guest_email if guest_email else '',
            inviterID=request.user,
            code=invitation_code,
            end_at=timezone.now() + timezone.timedelta(days=7)  # Valid for 7 days
        )
        
        # Send email if email was provided
        if guest_email:
            try:
                subject = 'You have been invited to join!'
                message = f"""
                                Hello,

                                You have been invited to join our platform!

                                Your invitation code is: {invitation_code}

                                This code is valid for 7 days. Use this code along with your email to register.

                                Regards,
                                Admin Team
                                """
                from_email = getattr(settings, 'DEFAULT_FROM_EMAIL', 'noreply@example.com')
                send_mail(
                    subject,
                    message,
                    from_email,
                    [guest_email],
                    fail_silently=False,
                )
                email_sent = True
            except Exception :
                email_sent = False
                # Still return success since the code was created
        else:
            email_sent = False
        
        return Response({
            'message': 'Invitation code generated successfully',
            'code': invitation_code,
            'email': guest_email,
            'expires_at': invite.end_at,
            'email_sent': email_sent
        }, status=status.HTTP_201_CREATED)
    
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
