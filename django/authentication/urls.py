
from django.urls import path
from .views import LoginAdminView, RegisterView, LoginView, ConfirmEmailView, GenerateInvitationCodeView, RenewTokenView

urlpatterns = [
    path('register/', RegisterView.as_view(), name='register'),
    path('login/', LoginView.as_view(), name='login'),
    path('login-admin/', LoginAdminView.as_view(), name='login-admin'),
    path('confirm-email/<str:token>/', ConfirmEmailView.as_view(), name='confirm-email'),
    path('generate-invite/', GenerateInvitationCodeView.as_view(), name='generate-invite'),
    path('renew-token/', RenewTokenView.as_view(), name='renew-token'),
]