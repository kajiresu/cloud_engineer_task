FROM python:3.9

WORKDIR /usr/app/src
COPY requirements.txt ./
RUN pip install --requirement ./requirements.txt

COPY code/analysis.py ./
COPY data/ ./

CMD [ "python3", "./analysis.py", "x_list.tsv", "y_list.tsv"]