from rest_framework import serializers
from .models import USERS

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

class RegisterSerializer(serializers.ModelSerializer):
    class Meta:
        model = USERS
        fields = ['name', 'email', 'password']
        extra_kwargs = {'password': {'write_only': True}}
    def create(self, validated_data):
        password = validated_data.pop('password', None)
        user = super().create(validated_data)
        if password:
            user.set_password(password)
            user.save()
        return user
    
class LoginSerializer(serializers.Serializer):
    email = serializers.EmailField()
    password = serializers.CharField(write_only=True)   

