FROM ollama/ollama:0.1.20 as build
# Download language model
ADD https://huggingface.co/TheBloke/Mistral-7B-OpenOrca-GGUF/resolve/main/mistral-7b-openorca.Q5_K_M.gguf .
COPY Modelfile ./mistral-7b-openorca.Q5_K_M.model
# Create model inside ollama
RUN nohup bash -c "ollama serve &" && sleep 2 && ollama create mistral-7b-openorca -f ./mistral-7b-openorca.Q5_K_M.model && pkill ollama

# ---

FROM ollama/ollama:0.1.20

# Install Python
RUN apt-get update && apt-get install -y --no-install-recommends \
python3 \
python3-pip \
python3-venv \
python-is-python3 \
&& \
apt-get clean && \
rm -rf /var/lib/apt/lists/*

# Create non-root user
RUN useradd -ms /bin/bash ollama
USER ollama
WORKDIR /home/ollama
SHELL ["/bin/bash", "-c"]

# Setup the virtual environment for python and install requirements
COPY requirements.txt .
RUN python -m venv venv && \
source venv/bin/activate && \
pip install --no-cache-dir -r requirements.txt && \
python -m nltk.downloader all && \
deactivate

# Copy the model
COPY --from=build --chown=ollama:ollama /root/.ollama/ ./.ollama/

COPY start-server.sh .
COPY ollama-with-local-docs.py .

ENTRYPOINT source venv/bin/activate && ./start-server.sh && ollama run mistral-7b-openorca
