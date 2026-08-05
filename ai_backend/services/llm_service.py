from llama_cpp import Llama

llm = None


def load_model(model_path: str):
    global llm

    llm = Llama(
        model_path=model_path,
        n_ctx=2048,
        n_threads=8,
        n_gpu_layers=-1,
        verbose=True,
    )


def ask(prompt: str):
    output = llm.create_chat_completion(
        messages=[
            {
                "role": "user",
                "content": prompt,
            }
        ],
        temperature=0.2,
        max_tokens=1500,
    )

    return output["choices"][0]["message"]["content"]