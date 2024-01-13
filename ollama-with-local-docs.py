import sys
from langchain.text_splitter import CharacterTextSplitter, RecursiveCharacterTextSplitter
from langchain.callbacks.manager import CallbackManager
from langchain.callbacks.streaming_stdout import StreamingStdOutCallbackHandler
from langchain.chains import ConversationalRetrievalChain, RetrievalQA
from langchain.indexes.vectorstore import VectorStoreIndexWrapper
from langchain.indexes import VectorstoreIndexCreator
from langchain_community.embeddings import OllamaEmbeddings
from langchain_community.vectorstores import Chroma
from langchain_community.document_loaders import DirectoryLoader, TextLoader, WebBaseLoader
from langchain_community.llms import Ollama

llm = Ollama(model="mistral-7b-openorca")

loader = DirectoryLoader("data/", show_progress=True, use_multithreading=True)

index = VectorstoreIndexCreator(
    vectorstore_cls=Chroma,
    embedding=OllamaEmbeddings(model="mistral-7b-openorca"),
    text_splitter=CharacterTextSplitter(chunk_size=1000, chunk_overlap=0)
).from_loaders([loader])

chain = ConversationalRetrievalChain.from_llm(
    llm=llm,
    retriever=index.vectorstore.as_retriever(search_kwargs={"k": 1}),
)

chat_history = []
try:
    while True:
        query = input(">>> ")
        result = chain.invoke({"question": query, "chat_history": chat_history})
        for chunk in chat.stream("Write me a song about goldfish on the moon"):
            print(chunk.content, end="", flush=True)
            print(result['answer'])

        chat_history.append((query, result['answer']))
except EOFError:
    pass
