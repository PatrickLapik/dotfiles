SHADER_DIR="./shaders"
OUTPUT_DIR="./shaders/.qsb"


if [ ! -d "$OUTPUT_DIR" ]; then
    echo "No $OUTPUT_DIR output dir"
    echo "Creating $OUTPUT_DIR"
    mkdir $OUTPUT_DIR
fi

for file in "$SHADER_DIR"/*; do
    if [ -f "$file" ]; then
        filename=$(basename "$file")
        qsb --qt6 -o "$OUTPUT_DIR/$filename.qsb" "$file"
    fi
done

