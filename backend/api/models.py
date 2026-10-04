from django.db import models

class House(models.Model):
    name = models.CharField(max_length=100)
    style = models.CharField(max_length=50)
    starting_price = models.FloatField()
    contractor_name = models.CharField(max_length=100)
    image_url = models.URLField()
    description = models.TextField()

class Appointment(models.Model):
    house_name = models.CharField(max_length=100)
    date = models.CharField(max_length=50)
    phone = models.CharField(max_length=20)
    created_at = models.DateTimeField(auto_now_add=True)