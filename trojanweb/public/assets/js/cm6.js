import { EditorState } from "@codemirror/state";
import { EditorView } from "@codemirror/view";

let state = EditorState.create({
  doc: "hello world"
});

new EditorView({
  state,
  parent: document.querySelector("#editor")
});
