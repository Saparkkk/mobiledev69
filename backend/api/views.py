from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
import json
from .models import House, Appointment
from django.contrib.auth import logout
from django.shortcuts import redirect

def get_houses(request):
    if request.method == 'GET':
        houses = list(House.objects.values())
        return JsonResponse(houses, safe=False)
    
@csrf_exempt
def handle_appointments(request):
    if request.method == 'GET':
        # ดึงข้อมูลการนัดหมายทั้งหมด
        appointments = Appointment.objects.all().values('id', 'house_name', 'date', 'phone') 
        # หมายเหตุ: ชื่อฟิลด์ใน values() ต้องตรงกับใน models.py ของคุณ (เช่น houseName หรือ house_name)
        
        # ส่งข้อมูลกลับไปให้ Flutter ในรูปแบบ List JSON
        return JsonResponse(list(appointments), safe=False)
    
    elif request.method == 'POST':
        try:
            data = json.loads(request.body)
            if isinstance(data, str):
                data = json.loads(data)
                
            # 🟢 ต้องมีคำสั่งนี้เพื่อบันทึกลง Database จริงๆ
            Appointment.objects.create(
                house_name=data.get('houseName', ''), 
                date=data.get('date', ''),
                phone=data.get('phone', '')
            )
            
            # ต้องบันทึกให้เสร็จก่อน ค่อย return 201
            return JsonResponse({"message": "Created successfully"}, status=201)
            
        except Exception as e:
            return JsonResponse({"error": str(e)}, status=400)

@csrf_exempt # อย่าลืม import csrf_exempt ด้วยถ้ายังไม่มี
def appointment_detail(request, pk):
    try:
        # ค้นหาข้อมูลนัดหมายจาก ID (pk)
        appointment = Appointment.objects.get(pk=pk)
    except Appointment.DoesNotExist:
        return JsonResponse({"error": "Appointment not found"}, status=404)

    # 🟢 คำสั่งลบข้อมูล (DELETE)
    if request.method == 'DELETE':
        appointment.delete()
        return JsonResponse({"message": "Deleted successfully"}, status=200)

    # 🔵 คำสั่งแก้ไขข้อมูล (PUT)
    elif request.method == 'PUT':
        try:
            data = json.loads(request.body)
            if isinstance(data, str):
                data = json.loads(data)
            
            # อัปเดตค่าใหม่
            appointment.house_name = data.get('houseName', appointment.house_name)
            appointment.date = data.get('date', appointment.date)
            appointment.phone = data.get('phone', appointment.phone)
            appointment.save() # บันทึกการแก้ไขลงฐานข้อมูล
            
            return JsonResponse({"message": "Updated successfully"}, status=200)
        except Exception as e:
            return JsonResponse({"error": str(e)}, status=400)

    return JsonResponse({"error": "Method not allowed"}, status=405)

def custom_logout(request):
    logout(request) # เคลียร์ Session Cookie ในเบราว์เซอร์
    # Redirect กลับมาที่แอป Flutter
    return redirect('http://localhost:50000/')