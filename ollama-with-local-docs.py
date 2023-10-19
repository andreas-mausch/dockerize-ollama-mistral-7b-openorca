import sys
from langchain.embeddings import OllamaEmbeddings
from langchain.vectorstores import Chroma
from langchain.text_splitter import CharacterTextSplitter, RecursiveCharacterTextSplitter
from langchain.document_loaders import DirectoryLoader, TextLoader, WebBaseLoader
from langchain.llms import Ollama
from langchain.callbacks.manager import CallbackManager
from langchain.callbacks.streaming_stdout import StreamingStdOutCallbackHandler
from langchain.chains import ConversationalRetrievalChain, RetrievalQA
from langchain.indexes.vectorstore import VectorStoreIndexWrapper
from langchain.indexes import VectorstoreIndexCreator

llm = Ollama(model="mistral")

loader = DirectoryLoader("data/", show_progress=True, use_multithreading=True)
print(loader.load())

index = VectorstoreIndexCreator(
    vectorstore_cls=Chroma,
    embedding=OllamaEmbeddings(model="mistral"),
    text_splitter=CharacterTextSplitter(chunk_size=1000, chunk_overlap=0)
).from_loaders([loader])

chain = ConversationalRetrievalChain.from_llm(
    llm=llm,
    retriever=index.vectorstore.as_retriever(search_kwargs={"k": 1}),
)

chat_history = []
while True:
    query = input("Prompt: ")
    result = chain({"question": query, "chat_history": chat_history})
    print(result['answer'])

    chat_history.append((query, result['answer']))
    query = None
