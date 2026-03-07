from rest_framework.authentication import BaseAuthentication
from rest_framework.exceptions import AuthenticationFailed
from django.utils import timezone
from .models import Token as CustomToken


class CustomTokenAuthentication(BaseAuthentication):
    """
    Custom authentication class that works with the custom Token model.
    """
    def authenticate(self, request):
        auth_header = request.headers.get('Authorization', '')
        
        if not auth_header:
            return None  # No authentication attempted
        
        try:
            token_value = auth_header.replace('Bearer ', '')
            token = CustomToken.objects.select_related('userID').get(value=token_value)
            
            # Check if token is expired
            if token.end_at and token.end_at < timezone.now():
                raise AuthenticationFailed('Token has expired.')
            
            return (token.userID, token)
        except CustomToken.DoesNotExist:
            raise AuthenticationFailed('Invalid token.')
