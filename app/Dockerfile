FROM python:3.11-slim-bookworm

WORKDIR /app

COPY requirements.txt requirements.txt
RUN pip3 install -r requirements.txt

COPY . .

CMD [ "python3", "-m" , "gunicorn", "-b", "0.0.0.0:8000", "-w", "2", "app:app" ]
