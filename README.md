A ready-to-run ollama dockerized together with the [Mistral-7B-OpenOrca-GGUF](https://huggingface.co/TheBloke/Mistral-7B-OpenOrca-GGUF) language model.

The reason for this project is to have a ready-to-use docker image which I can store on my drive and spin it up whenever I want to,
without the need for an internet connection.

# Build, run and save the image

```bash
docker build -t ollama-mistral-7b-openorca .
docker run -it --rm ollama-mistral-7b-openorca
docker save -o ollama-mistralorca-docker.tar ollama-mistral-7b-openorca
# docker load -i ollama-mistralorca-docker.tar
```

# Instruction template

See [here (reddit.com)](https://www.reddit.com/r/LocalLLaMA/comments/16y5nq8/comment/k388mwb/).

> To get it working in oobabooga's text-generation-webui, you need the correct instruction template, which isn't available by default. In your text-generation-webui directory, go into the folder instruction-templates/ and create file mistral-openorca.yaml with the contents
>
> ```
> user: <|im_start|>user
> bot: |-
>   <|im_end|>
>   <|im_start|>assistant
> turn_template: '<|user|>\n<|user-message|>\n<|bot|>\n<|bot-message|><|im_end|>\n'
> ```
>
> Then load it in ooba by going to parameters -> instruction template, refresh the dropdown and select mistral-openorca. 

I've tried to configure the TEMPLATE in a way it works well with the model, but in some cases the AI continues the conversation by itself:
It doesn't stop after it's own answer, but continues the dialogue by writing another question from Human perspective and answering that again and so on.

This doesn't happen too often though, and beside that the model works well.
