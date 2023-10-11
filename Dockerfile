FROM ollama/ollama as build
ADD https://huggingface.co/TheBloke/Mistral-7B-OpenOrca-GGUF/resolve/main/mistral-7b-openorca.Q5_K_M.gguf .
# Note: The lines with a hashtag (#) as the first character are ignored by docker,
# because it thinks it is a comment. That's why I have put them behind another line.
RUN printf 'FROM ./mistral-7b-openorca.Q5_K_M.gguf\n\
\n\
PARAMETER temperature 1\n\
\n\
TEMPLATE """\n\
{{- if .First }}\n### System:\n\
{{ .System }}\n\
{{- end }}\n\
\n### Human:\n\
{{ .Prompt }}\n\
\n### Assistant:\n\
"""\n\
\n\
SYSTEM """\n\
"""\n' > ./mistral-7b-openorca.Q5_K_M.model
RUN nohup bash -c "ollama serve &" && sleep 2 && ollama create mistral-7b-openorca -f ./mistral-7b-openorca.Q5_K_M.model && pkill ollama

FROM ollama/ollama
COPY --from=build /root/.ollama/ /root/.ollama/
# See here how to solve CTRL+C should not kill 'ollama serve':
# https://superuser.com/questions/708919/ctrlc-in-a-sub-process-is-killing-a-nohuped-process-earlier-in-the-script
ENTRYPOINT ( setsid ollama serve >/dev/null 2>&1 & ) && sleep 2 && ollama run mistral-7b-openorca
