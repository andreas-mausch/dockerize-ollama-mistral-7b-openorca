FROM ollama/ollama:0.1.3 as build

# Download language model
ADD https://huggingface.co/TheBloke/Mistral-7B-OpenOrca-GGUF/resolve/main/mistral-7b-openorca.Q5_K_M.gguf .

# Setup model description file
RUN printf 'FROM ./mistral-7b-openorca.Q5_K_M.gguf\n\
\n\
PARAMETER temperature 1\n\
PARAMETER stop "<|im_start|>"\n\
PARAMETER stop "<|im_end|>"\n\
\n\
TEMPLATE """\n\
{{- if .System }}\n\
<|im_start|>system {{ .System }}<|im_end|>\n\
{{- end }}\n\
<|im_start|>user\n\
{{ .Prompt }}<|im_end|>\n\
<|im_start|>assistant\n\
"""\n\
\n\
SYSTEM """\n\
"""\n' > ./mistral-7b-openorca.Q5_K_M.model
# Create model inside ollama
RUN nohup bash -c "ollama serve &" && sleep 2 && ollama create mistral-7b-openorca -f ./mistral-7b-openorca.Q5_K_M.model && pkill ollama

# ---

FROM ollama/ollama:0.1.3

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

COPY --from=build /root/.ollama/ ./.ollama/
COPY ollama-with-local-docs.py .
COPY requirements.txt .

# Setup the virtual environment for python
RUN python -m venv venv && \
source venv/bin/activate && \
pip install -r requirements.txt && \
deactivate

# See here how to solve CTRL+C should not kill 'ollama serve':
# https://superuser.com/questions/708919/ctrlc-in-a-sub-process-is-killing-a-nohuped-process-earlier-in-the-script
ENTRYPOINT ( setsid ollama serve >/dev/null 2>&1 & ) && sleep 2 && ollama run mistral-7b-openorca
