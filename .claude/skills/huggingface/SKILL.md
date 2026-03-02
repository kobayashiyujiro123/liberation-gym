---
name: huggingface
description: Comprehensive Hugging Face development guide covering CLI operations, model training/fine-tuning, datasets, evaluation, compute jobs, tool building, paper publishing, experiment tracking with Trackio, and MCP server integration. Use when working with ML models, datasets, or the Hugging Face platform. Source - huggingface/skills official partner repository.
tools: Read, Write, Edit, Bash, Glob, Grep
---

# Hugging Face Development Guide

Comprehensive guide for the Hugging Face platform. Source: `huggingface/skills` official partner repository.

## HF CLI

### Installation & Auth

```bash
pip install huggingface_hub
huggingface-cli login
```

### Model Operations

```bash
# Download model
huggingface-cli download meta-llama/Llama-3-8B-Instruct --local-dir ./model

# Upload model
huggingface-cli upload my-org/my-model ./model --repo-type model

# Search models
huggingface-cli search models --query "text-generation" --limit 10
```

### Dataset Operations

```bash
# Download dataset
huggingface-cli download my-org/my-dataset --repo-type dataset --local-dir ./data

# Upload dataset
huggingface-cli upload my-org/my-dataset ./data --repo-type dataset
```

### Repo Management

```bash
# Create repo
huggingface-cli repo create my-model --type model
huggingface-cli repo create my-dataset --type dataset

# Cache management
huggingface-cli cache info
huggingface-cli cache clean
```

---

## Model Training / Fine-Tuning (TRL)

### Supervised Fine-Tuning (SFT)

```python
from trl import SFTTrainer, SFTConfig
from transformers import AutoModelForCausalLM, AutoTokenizer

model = AutoModelForCausalLM.from_pretrained("meta-llama/Llama-3-8B")
tokenizer = AutoTokenizer.from_pretrained("meta-llama/Llama-3-8B")

config = SFTConfig(
    output_dir="./output",
    max_seq_length=2048,
    per_device_train_batch_size=4,
    gradient_accumulation_steps=4,
    learning_rate=2e-5,
    num_train_epochs=3,
    logging_steps=10,
    push_to_hub=True,
    hub_model_id="my-org/my-finetuned-model",
)

trainer = SFTTrainer(
    model=model,
    tokenizer=tokenizer,
    train_dataset=dataset,
    args=config,
)
trainer.train()
```

### DPO (Direct Preference Optimization)

```python
from trl import DPOTrainer, DPOConfig

config = DPOConfig(
    output_dir="./dpo-output",
    per_device_train_batch_size=4,
    learning_rate=5e-7,
    beta=0.1,
    num_train_epochs=1,
)

trainer = DPOTrainer(
    model=model,
    ref_model=ref_model,
    tokenizer=tokenizer,
    train_dataset=preference_dataset,
    args=config,
)
```

### GRPO (Group Relative Policy Optimization)

```python
from trl import GRPOTrainer, GRPOConfig

config = GRPOConfig(
    output_dir="./grpo-output",
    per_device_train_batch_size=4,
    num_generations=4,
    learning_rate=1e-6,
)
```

### Hardware Selection

| Model Size | Recommended GPU | VRAM |
|-----------|----------------|------|
| ≤ 3B | 1x A10G | 24GB |
| 7-8B | 1x A100 | 40/80GB |
| 13B | 2x A100 | 80GB each |
| 70B | 4-8x A100 | 80GB each |

---

## Datasets

### Creating Datasets

```python
from datasets import Dataset, DatasetDict

# From dict
dataset = Dataset.from_dict({
    "text": ["Hello", "World"],
    "label": [0, 1],
})

# From pandas
dataset = Dataset.from_pandas(df)

# Push to Hub
dataset.push_to_hub("my-org/my-dataset")
```

### Chat Format

```python
dataset = Dataset.from_dict({
    "messages": [
        [
            {"role": "system", "content": "You are helpful."},
            {"role": "user", "content": "Hello"},
            {"role": "assistant", "content": "Hi! How can I help?"},
        ],
    ]
})
```

### SQL-Based Querying (DuckDB)

```python
from datasets import load_dataset
import duckdb

dataset = load_dataset("my-org/my-dataset", split="train")
df = dataset.to_pandas()

result = duckdb.sql("""
    SELECT label, COUNT(*) as count
    FROM df
    GROUP BY label
    ORDER BY count DESC
""").fetchdf()
```

---

## Model Evaluation

### Using lighteval

```bash
pip install lighteval

lighteval run \
    --model "meta-llama/Llama-3-8B-Instruct" \
    --tasks "mmlu|5|0,hellaswag|10|0" \
    --output_dir ./results
```

### Using vLLM for Fast Inference

```bash
pip install vllm

lighteval run \
    --model "meta-llama/Llama-3-8B-Instruct" \
    --model_backend vllm \
    --tasks "mmlu|5|0"
```

---

## HF Jobs (Compute)

### UV Script Jobs

```python
# /// script
# requires-python = ">=3.10"
# dependencies = ["transformers", "torch"]
# ///

from transformers import pipeline
pipe = pipeline("text-generation", model="meta-llama/Llama-3-8B-Instruct")
result = pipe("Hello, how are you?")
print(result)
```

```bash
# Run on HF infrastructure
huggingface-cli jobs run my-script.py --hardware a10g-small
```

### Docker Jobs

```bash
huggingface-cli jobs run --docker ./my-docker-project --hardware a10g-small
```

---

## Experiment Tracking (Trackio)

```python
import trackio

# Initialize run
trackio.init(
    project="my-project",
    run_name="experiment-1",
    config={"lr": 2e-5, "epochs": 3},
)

# Log metrics
for step in range(100):
    trackio.log({"loss": loss, "accuracy": acc}, step=step)

# Finish
trackio.finish()
```

Dashboard syncs to HF Spaces for real-time monitoring.

---

## MCP Server Integration

```json
{
  "mcpServers": {
    "huggingface": {
      "type": "stdio",
      "command": "npx",
      "args": ["-y", "@huggingface/mcp-server"],
      "env": {
        "HF_TOKEN": "hf_..."
      }
    }
  }
}
```

### Available MCP Tools

- Search models, datasets, Spaces, papers
- Run GPU jobs
- Use Gradio Spaces as tools
- Download/upload files
- Manage repositories

---

## GGUF Conversion

Convert models to GGUF format for local inference (llama.cpp):

```bash
pip install llama-cpp-python

# Convert from HF format
python convert_hf_to_gguf.py ./model --outfile model.gguf --outtype f16

# Quantize
./quantize model.gguf model-Q4_K_M.gguf Q4_K_M
```

### Common Quantization Types

| Type | Size Reduction | Quality |
|------|---------------|---------|
| Q8_0 | ~50% | Near-original |
| Q6_K | ~40% | Very good |
| Q4_K_M | ~25% | Good balance |
| Q4_K_S | ~25% | Slightly lower |
| Q2_K | ~15% | Noticeable degradation |
