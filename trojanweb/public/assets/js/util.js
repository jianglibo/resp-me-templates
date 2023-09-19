function toggleNextElement(button, elementType, elementClass) {
	var nextElement = button.nextElementSibling;
	while (nextElement) {
		if (nextElement.tagName.toLowerCase() === elementType.toLowerCase() &&
			(!elementClass || nextElement.classList.contains(elementClass))) {
			if (nextElement.style.display === 'none' || nextElement.style.display === '') {
				nextElement.style.display = 'block'; // Show the element
			} else {
				nextElement.style.display = 'none'; // Hide the element
			}
			break; // Stop searching once the element is found
		}
		nextElement = nextElement.nextElementSibling;
	}
}

htmx.defineExtension('disable-element', {
    onEvent: function (name, evt) {
        let elt = evt.detail.elt;
        let target = elt.getAttribute("hx-disable-element");
        let targetElement = (target == "self") ? elt : document.querySelector(target);

        if (name === "htmx:beforeRequest" && targetElement) {
            targetElement.disabled = true;
        } else if (name == "htmx:afterRequest" && targetElement) {
            targetElement.disabled = false;
        }
    }
});