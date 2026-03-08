import uuid
from django.db import models
from django.contrib.auth.models import AbstractBaseUser, BaseUserManager,PermissionsMixin

# Manager nécessaire pour gérer la création d'utilisateurs avec AbstractBaseUser
class UserManager(BaseUserManager):
    def create_user(self, email, password=None, **extra_fields):
        if not email: raise ValueError("Input email")
        email = self.normalize_email(email)
        user = self.model(email=email, **extra_fields)
        user.set_password(password) # Hash password
        user.isBlocked = extra_fields.get('isBlocked', False)
        user.is_staff = extra_fields.get('is_staff', False)
        user.is_superuser = extra_fields.get('is_superuser', False)
        user.save(using=self._db)
        return user
    
    def create_superuser(self, email, password=None, **extra_fields):
        extra_fields.setdefault('is_staff', True)
        extra_fields.setdefault('is_superuser', True)
        extra_fields.setdefault('isBlocked', False)
        if extra_fields.get('is_staff') is not True: raise ValueError("Superuser must have is_staff=True.")
        if extra_fields.get('is_superuser') is not True: raise ValueError("Superuser must have is_superuser=True.")
        return self.create_user(email, password, **extra_fields)

class USERS(AbstractBaseUser,PermissionsMixin): # Utilise AbstractBaseUser pour l'auth
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    name = models.CharField(max_length=150, unique=False)
    email = models.EmailField(unique=True)
    # password est déjà géré par AbstractBaseUser
    is_staff = models.BooleanField(default=False) # Pour admin site
    is_superuser = models.BooleanField(default=False) # Pour permissions
    isBlocked = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)

    objects = UserManager()
    USERNAME_FIELD = 'email' # On se connecte avec l'email
    REQUIRED_FIELDS = ['name']

class Token(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    # Utilise 'settings.AUTH_USER_MODEL' au lieu de USERS directement (meilleure pratique)
    userID = models.ForeignKey('USERS', on_delete=models.CASCADE)
    value = models.CharField(max_length=255, unique=True)
    created_at = models.DateTimeField(auto_now_add=True)
    end_at = models.DateTimeField()


