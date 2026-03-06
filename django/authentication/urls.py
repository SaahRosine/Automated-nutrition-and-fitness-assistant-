
from django.urls import path
from .views import RegisterView, LoginView, ConfirmEmailView, GenerateInvitationCodeView

urlpatterns = [
    path('register/', RegisterView.as_view(), name='register'),
    path('login/', LoginView.as_view(), name='login'),
    path('confirm-email/<str:token>/', ConfirmEmailView.as_view(), name='confirm-email'),
    path('generate-invite/', GenerateInvitationCodeView.as_view(), name='generate-invite'),
]