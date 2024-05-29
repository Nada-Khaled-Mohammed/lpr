from licence_detectors.licence_plate_recognition_code.lpr import process_image as process_lpr_image

from fastapi import FastAPI, HTTPException, status
from pydantic import BaseModel
import requests
import json
import cv2
import os

import io
import base64
import numpy as np
from PIL import Image

app = FastAPI()


@app.get("/")
def index():
    return { "Response": "Hello from LPR:)"}
# https://img.freepik.com/premium-vector/whatsapp-icon-concept_23-2147897840.jpg?size=338&ext=jpg&ga=GA1.1.553209589.1715385600&semt=ais_user


class Licence_Request(BaseModel):
    source_base64: str
    uuid: str
    type: str ## either image or video


## DONE
# @app.post('/get-car-plate-data')
@app.post('/api/v1/ocr/plate')
def getCarPlateData(licence_request: Licence_Request):

    try:
        os.makedirs('lpr_images', exist_ok=True)
        
        print("\n\n\nos.path.exists(folder)", os.path.exists("lpr_images"))

        decoded_img = base64.b64decode(licence_request.source_base64)
        pil_img = Image.open(io.BytesIO(decoded_img))
        colored_img = cv2.cvtColor(np.array(pil_img), cv2.COLOR_BGR2RGB)
        cv2.imwrite('./lpr_images/lpr_img.jpg', colored_img)


        downloaded_img = cv2.imread("./lpr_images/lpr_img.jpg")

        print("\n\n\nlpr_img.jpg", os.path.exists("./lpr_images/lpr_img.jpg"))
        print("\n\n\ndownloaded_img::", type(downloaded_img))

        lpr_data = process_lpr_image(downloaded_img)
        # os.remove("./lpr_images/lpr_img.jpg")

        return{
            "uuid": licence_request.uuid,
            "data": {
                "plate_number": lpr_data 
            }
        }
    except Exception as e:
        print(e)
        return{
            "uuid": licence_request.uuid,
            "data": {
                "plate_number": ""
            }
        }
    
        # raise HTTPException(
        #     status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
        #     detail="Internal Server Error"
        # ) from e

