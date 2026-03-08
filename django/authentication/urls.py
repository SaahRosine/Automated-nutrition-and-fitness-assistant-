
from django.urls import path
from .views import LoginAdminView, LogoutView, RegisterNormalView, RegisterAdminView, LoginView,RenewTokenView

urlpatterns = [
    path('register-admin/', RegisterAdminView.as_view(), name='register-admin'),
    path('register-normal/', RegisterNormalView.as_view(), name='register-normal'),
    path('login/', LoginView.as_view(), name='login'),
    path('login-admin/', LoginAdminView.as_view(), name='login-admin'),
    path('renew-token/', RenewTokenView.as_view(), name='renew-token'),
    path('logout/', LogoutView.as_view(), name='logout'),
]