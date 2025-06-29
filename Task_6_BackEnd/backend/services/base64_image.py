import base64

with open("Ashleyy.jpg", "rb") as f:
    img_bytes = f.read()
    base64_bytes = base64.b64encode(img_bytes)
    base64_str = base64_bytes.decode('utf-8').replace("\n", "").replace("\r", "")

base64_image = f"data:image/jpeg;base64,{base64_str}"
print(base64_image)
