from django.urls import path
from . import views
from .views import custom_logout

urlpatterns = [
    path('houses/', views.get_houses),
    path('appointments/', views.handle_appointments),
    path('appointments/<int:pk>/', views.appointment_detail, name='appointment_detail'),
    path('logout/', custom_logout, name='custom_logout'),
]