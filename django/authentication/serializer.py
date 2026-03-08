from rest_framework import serializers
from decouple import config

class AdminSerializer(serializers.Serializer):
    name = serializers.CharField(max_length=150)
    email = serializers.EmailField()
    password = serializers.CharField(write_only=True)
    code = serializers.CharField(required=False, allow_blank=True)
    
    def validate(self, data):
        code = data.get('code')
        env_code= config('ADMIN_CODE')
        if code:
            # Validate the code here
            if code != env_code:
                raise serializers.ValidationError("Invalid admin code.")
        return data

class NormalUserSerializer(serializers.Serializer):
    name = serializers.CharField(max_length=150)
    email = serializers.EmailField()
    password = serializers.CharField(write_only=True)
    code = serializers.CharField(required=False, allow_blank=True)
    
    def validate(self, data):
        code = data.get('code')
        env_code= config('NORMAL_USER_CODE')
        if code:
            # Validate the code here
            if code != env_code:
                raise serializers.ValidationError("Invalid normal user code.")
        return data

class LoginSerializer(serializers.Serializer):
    email = serializers.EmailField()
    password = serializers.CharField(write_only=True)   

