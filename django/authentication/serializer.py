from rest_framework import serializers
from .models import USERS, InvitationCode
from django.utils import timezone

class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = USERS
        fields = [ 'name', 'email','password','code']
        extra_kwargs = {'password': {'write_only': True}}
        read_only_fields = ['created_at']
    def create(self, validated_data):
        password = validated_data.pop('password', None)
        user = super().create(validated_data)
        if password:
            user.set_password(password)
            user.save()
        return user

class RegisterSerializer(serializers.Serializer):
    name = serializers.CharField(max_length=150)
    email = serializers.EmailField()
    password = serializers.CharField(write_only=True)
    admin_code = serializers.CharField(required=False, allow_blank=True)
    invitation_code = serializers.CharField(required=False, allow_blank=True)
    
    def validate(self, data):
        admin_code = data.get('admin_code', '')
        invitation_code = data.get('invitation_code', '')
        
        # If neither code is provided, allow registration (or reject based on requirements)
        # For now, require at least one code
        if not admin_code and not invitation_code:
            raise serializers.ValidationError("Either admin_code or invitation_code is required.")
        
        # If admin code provided, validate it
        if admin_code:
            # You can set your admin code here or in settings
            from django.conf import settings
            valid_admin_code = getattr(settings, 'ADMIN_REGISTRATION_CODE', 'admin_secret_2024')
            if admin_code != valid_admin_code:
                raise serializers.ValidationError("Invalid admin code.")
        
        # If invitation code provided, validate it
        if invitation_code:
            try:
                inv_code = InvitationCode.objects.get(code=invitation_code)
                # Check if code is expired
                if inv_code.end_at and inv_code.end_at < timezone.now():
                    raise serializers.ValidationError("Invitation code has expired.")
                # Check if code was already used
                if inv_code.isTried:
                    raise serializers.ValidationError("Invitation code has already been used.")
                # Check if email matches (if specified)
                if inv_code.guestEmail and inv_code.guestEmail != data.get('email'):
                    raise serializers.ValidationError("Invitation code is not valid for this email.")
            except InvitationCode.DoesNotExist:
                raise serializers.ValidationError("Invalid invitation code.")
        
        return data
    
    def create(self, validated_data):
        password = validated_data.pop('password')
        admin_code = validated_data.pop('admin_code', '')
        invitation_code = validated_data.pop('invitation_code', '')
        
        # Determine if admin or regular user
        from django.conf import settings
        valid_admin_code = getattr(settings, 'ADMIN_REGISTRATION_CODE', 'admin_secret_2024')
        
        is_admin = False
        if admin_code == valid_admin_code:
            is_admin = True
        
        # Create user
        user = USERS.objects.create_user(
            email=validated_data['email'],
            name=validated_data['name'],
            password=password,
            is_staff=is_admin,
            is_superuser=is_admin
        )
        
        # Mark invitation code as used
        if invitation_code:
            try:
                inv_code = InvitationCode.objects.get(code=invitation_code)
                inv_code.isTried = True
                inv_code.save()
            except InvitationCode.DoesNotExist:
                pass
        
        return user
    
class LoginSerializer(serializers.Serializer):
    email = serializers.EmailField()
    password = serializers.CharField(write_only=True)   

