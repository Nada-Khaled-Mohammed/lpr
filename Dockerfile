FROM python:3.10.11-slim

## to avoid the raised error for missing dependencies of OpenCV in Linux
RUN apt-get update
RUN apt-get install -y libopencv-dev
# RUN rm -rf /var/lib/apt/lists/*


## This command will install torch for CPU, cause YOLO needs this package but YOLO will install
## the GPU version, so, we will install the torch package for CPU independently,
## so YOLO will find it so it will not install it
##  -- size el image after this installation ~ 1.4 GB
RUN pip3 install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cpu
## install tensorflow for CPU -- size el image after this installation = 3.77GB
# RUN pip install tensorflow
RUN pip install tensorflow==2.13.0

COPY models_only_requirements.txt .
## -- size el image after this installation =  5.22GB
# RUN pip install --no-cache-dir -r requirements_with_fast_api.txt
RUN pip install -r models_only_requirements.txt

COPY ocr_package-0.0.1-py2.py3-none-any.whl .
# RUN echo "### After copying files i have these:" && ls -la

## to avoid the raised error: No module named 'skimage'
RUN pip install scikit-image
RUN pip install ocr_package-0.0.1-py2.py3-none-any.whl

RUN pip install fastapi uvicorn

########################## For LPR project ##########################
RUN pip install pillow
RUN pip install ultralytics
RUN pip install hydra-core
RUN pip install gitpython
RUN apt-get update
RUN apt-get install -y git

# RUN export GIT_PYTHON_GIT_EXECUTABLE=$(which git)
# ENV GIT_PYTHON_GIT_EXECUTABLE $(which git)
ENV GIT_PYTHON_GIT_EXECUTABLE /usr/bin/git


##########################

COPY main.py .
COPY /licence_detectors /licence_detectors

# CMD ["python", "car_license_ocr.py"]
# CMD ["uvicorn", "main:app", "--port", "8005", "--reload"]

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8082", "--reload"]