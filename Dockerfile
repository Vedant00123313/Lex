FROM ubuntu:24.04

# 1. Install required build tools (gcc, flex, make)
RUN apt-get update && apt-get install -y \
    build-essential \
    flex \
    && rm -rf /var/lib/apt/lists/*

# 2. Set the working directory inside the container
WORKDIR /app

# 3. Copy your project files (Make sure cpp_lexer.l and input.cpp are in this folder!)
COPY . .

# 4. Generate the lexer and compile it during the image build stage
RUN flex cpp_lexer.l
RUN gcc lex.yy.c -o cpp_lexer -lfl

# 5. Execute the lexer automatically when the container starts
CMD ["./cpp_lexer", "input.cpp"]
