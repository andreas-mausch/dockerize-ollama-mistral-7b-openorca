# AI: text-generation

A ready-to-run ollama dockerized together with the [Mistral-7B-OpenOrca-GGUF](https://huggingface.co/TheBloke/Mistral-7B-OpenOrca-GGUF) language model.

The reason for this project is to have a ready-to-use docker image which I can store on my drive and spin it up whenever I want to,
without the need for an internet connection.

This image also uses [langchain](https://www.langchain.com/) to use local documents with the language model.

Update: ollama has added the `mistral-openorca` model as a default option [here](https://ollama.ai/library/mistral-openorca),
which most likely has the better template defined.
Please use it instead of this repo if you don't need it dockerized.

See also [my AI list on github.com](https://github.com/stars/andreas-mausch/lists/ai).

# Build, run and save the image

```bash
docker build -t ollama-mistral-7b-openorca .
docker run -it --rm --network none ollama-mistral-7b-openorca
docker save -o ollama-mistralorca-docker.tar ollama-mistral-7b-openorca
# docker load -i ollama-mistralorca-docker.tar
```

Note: I use docker's [none network driver](https://docs.docker.com/network/drivers/none/) to ensure everythings runs locally and no private data is exposed to the internet.

# Run with local docs

GPT4All has a cool feature: LocalDocs Beta Plugin (Chat With Your Data)

You can provide additional files with private information which will also be used by the language model.
The same can be achieved with ollama and langchain. See the commands below.
The extra data is inside the folder `data/`. You can add your own documents.

```bash
docker run -it --rm --network none -v $PWD/data:/home/ollama/data:ro --entrypoint bash ollama-mistral-7b-openorca -c 'source venv/bin/activate && ./start-server.sh && python ollama-with-local-docs.py'
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

I've tried to configure the [TEMPLATE](https://github.com/jmorganca/ollama/blob/main/docs/modelfile.md#template)
in a way it works well with the model, but in some cases the AI continues the conversation by itself:
It doesn't stop after it's own answer, but continues the dialogue by writing another question from Human perspective and answering that again and so on.

This doesn't happen too often though, and beside that the model works well.
