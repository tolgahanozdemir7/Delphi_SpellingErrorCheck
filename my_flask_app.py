from flask import Flask, request, jsonify
import language_tool_python

app = Flask(__name__)
tool = language_tool_python.LanguageTool('en-US')  # Dil seçeneğini ihtiyacınıza göre değiştirebilirsiniz

@app.route('/correct', methods=['POST'])
def correct():
    data = request.json
    text = data.get('text', '')
    matches = tool.check(text)
    corrected_text = tool.correct(text)
    return jsonify({"corrected_text": corrected_text})

if __name__ == '__main__':
    app.run(host='127.0.0.1', port=5000)
