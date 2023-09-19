function path_lang() {
	var currentPath = window.location.pathname;
	var pathParts = currentPath.split('/');
	// The first part of the path will be at index 1 (index 0 will be an empty string)
	var firstPathPart = pathParts[1];
	console.log(firstPathPart);
	return firstPathPart || 'en';
}

const clientI18n = {
	en: {
		Confirm: 'Confirm',
		Cancel: 'Cancel',
		'Error!': 'Error!',
		'You cannot delete yourself.': 'You cannot delete yourself.',
		'Do you want to continue?': 'Do you want to continue?',
		'You are not admin!': 'You are not admin!',
		'Should delete the configurations first.': 'Should delete the configurations first.',
		'Cannot download file': 'Cannot download file',
		'Malformed YAML!': 'Malformed YAML!',
	},
	fa: {
		Confirm: 'تایید',
		Cancel: 'لغو',
		'Error!': 'خطا!',
		'You cannot delete yourself.': 'شما نمی‌توانید خودتان را حذف کنید.',
		'Do you want to continue?': 'آیا می‌خواهید ادامه دهید؟',
		'You are not admin!': 'شما مدیر نیستید!',
		'Should delete the configurations first.': 'ابتدا باید پیکربندی‌ها را حذف کنید.',
		'Cannot download file': 'دانلود فایل امکان‌پذیر نیست',
		'Malformed YAML!': 'YAML نادرست!',
	},
	zh: {
		Confirm: '确认',
		Cancel: '取消',
		'Error!': '错误！',
		'You cannot delete yourself.': '您不能删除自己。',
		'Do you want to continue?': '您确定要继续吗？',
		'You are not admin!': '你不是管理员！',
		'Should delete the configurations first.': '应该先删除配置。',
		'Cannot download file': '无法下载文件',
		'Malformed YAML!': '格式错误的 YAML！',
	},
	ja: {
		Confirm: '確認',
		Cancel: 'キャンセル',
		'Error!': 'エラー！',
		'You cannot delete yourself.': '自分自身を削除することはできません。',
		'Do you want to continue?': '続行しますか？',
		'You are not admin!': 'あなたは管理者ではありません！',
		'Should delete the configurations first.': '最初に構成を削除する必要があります。',
		'Cannot download file': 'ファイルをダウンロードできません',
		'Malformed YAML!': '形式が正しくない YAML！',
	},
	ko: {
		Confirm: '확인',
		Cancel: '취소',
		'Error!': '오류!',
		'You cannot delete yourself.': '자신을 삭제 할 수 없습니다.',
		'Do you want to continue?': '계속 하시겠습니까?',
		'You are not admin!': '당신은 관리자가 아닙니다! ',
		'Should delete the configurations first.': '먼저 구성을 삭제해야합니다.',
		'Cannot download file': '파일을 다운로드 할 수 없습니다',
		'Malformed YAML!': '잘못된 YAML!',
	},
};

// this is english version example: {title => 'Confirm', text => 'Do you want to continue?', icon => 'warning', confirmButtonText => 'Confirm'};
function translateSwalCfg(origin) {
	const lang = path_lang();
	const swalcfg = { ...origin }
	swalcfg.title = clientI18n[lang][origin.title] || origin.title;
	swalcfg.text = clientI18n[lang][origin.text] || origin.text;
	swalcfg.cancelButtonText = clientI18n[lang][origin.cancelButtonText]
		|| origin.cancelButtonText
		|| clientI18n[lang]['Cancel']
		|| 'Cancel';
	swalcfg.confirmButtonText = clientI18n[lang][origin.confirmButtonText]
		|| origin.confirmButtonText
		|| clientI18n[lang]['Confirm']
		|| 'Confirm';
	return swalcfg;
}


document.addEventListener('htmx:afterSwap', function (event) {
	// Check if the event target has an id of the input element you want to focus on
	if (event.target.tagName === 'INPUT') {
		// Set focus on the input element
		event.target.focus();
	} else {
		console.log("htmx:afterSwap", event.target)
	}
});

function copyToClipboard(that, evt) {
	evt.preventDefault();
	if (evt.stopPropagation) {
		evt.stopPropagation(); // Standard way
	} else {
		evt.cancelBubble = true; // For older IE versions
	}

	const copied_languages = {
		en: 'copied',
		zh: '已复制',
		ja: 'コピー済み',
		ko: '복사 됨',
	}

	const toCopyMessage = evt.target.dataset.toCopyMessage;
	if (!toCopyMessage) {
		return
	}
	const clipboardItem = new ClipboardItem({ "text/plain": new Blob([toCopyMessage], { type: "text/plain" }) });
	// Write the ClipboardItem to the clipboard
	navigator.clipboard.write([clipboardItem]).then(function () {
		console.log('Text copied to clipboard: ' + toCopyMessage);
		const label = that.innerHTML

		that.innerHTML = copied_languages[path_lang()]
		setTimeout(function () {
			that.innerHTML = label;
		}, 2000);
	}).catch(function (err) {
		console.error('Failed to copy text: ', err);
	});

}

document.body.addEventListener("newClient", function (e) {
	const htmlString = e.detail.value;
	const parentElement = document.getElementById('clients-table');
	parentElement.insertAdjacentHTML('afterbegin', htmlString);
	htmx.process(parentElement)
});

document.body.addEventListener("newError", function (e) {
	const htmlString = e.detail.value;
	const swalcfg = JSON.parse(htmlString);
	Swal.fire(translateSwalCfg(swalcfg));
});

document.body.addEventListener("newConfig", function (e) {
	const htmlString = e.detail.value;
	console.log(htmlString)
	var decodedString = htmlString;

	const parentElement = document.getElementById('configs-table');
	parentElement.insertAdjacentHTML('afterbegin', decodedString);
	document.querySelectorAll(".empty-place-holder").forEach((empty_place_holder_row) => {
		empty_place_holder_row.remove();
	});

	htmx.process(parentElement)
});

document.body.addEventListener("newDownload", function (e) {
	const htmlString = e.detail.value;
	// var decodedString = atob(htmlString);
	// var decodedString = decodeURIComponent(htmlString);
	var decodedString = htmlString;

	const parentElement = document.getElementById('downloads-table');
	// alert(decodedString);
	parentElement.insertAdjacentHTML('afterbegin', decodedString);
	htmx.process(parentElement)
});

function table_single_select(element_id) {
	// Delegate the click event to the table, so it works for dynamically added rows
	const tableElement = document.getElementById(element_id);

	if (!tableElement) {
		return;
	}

	tableElement.addEventListener('click', function (event) {
		// Check if the clicked element is a table row
		// Check if the clicked element or its parent is a table row
		const rows = tableElement.querySelectorAll('tr');
		let target = event.target;
		if (target.tagName === 'BUTTON') {
			return
		}
		while (target && target.tagName !== 'TR') {
			target = target.parentNode;
		}

		// If a table row was found, handle the click
		if (target && target.tagName === 'TR') {
			if (target.classList.contains('selected')) {
				target.classList.remove('selected')
				return
			}
			// Remove the 'selected' class from all rows
			rows.forEach(row => row.classList.remove('selected'));
			// Add the 'selected' class to the clicked row
			target.classList.add('selected');
		}
	});
}

table_single_select('clients-table-out');
table_single_select('configs-table-out');
table_single_select('downloads-table-out');

// Options for the observer (which mutations to observe)
const config = { childList: true, subtree: true };

// Callback function to execute when mutations are observed
const callback = (mutationList, observer) => {
	for (const mutation of mutationList) {
		if (mutation.type === "childList" && mutation.addedNodes.length > 0) {

			mutation.addedNodes.forEach((node) => {
				if (node instanceof HTMLElement) {
					// console.log("A child node has been added.", node);
					// Check if the node is an HTMLElement (e.g., a div, span, etc.)
					// extract this method to standalone method.
					// if (node.classList.contains('contains-cm')) {
					node.querySelectorAll(".cm-editor-wrap").forEach(function (cm_wrap) {
						const ipt = cm_wrap.querySelector('input');
						const myv = cm6(ipt.value, (v) => {
							ipt.value = v;
						});
						cm_wrap.appendChild(myv.dom);
					});
					// }
				}
			});
		}
	}
};

// Create an observer instance linked to the callback function
const observer = new MutationObserver(callback);

// Start observing the target node for configured mutations
observer.observe(document.body, config);

document.querySelectorAll(".cm-editor-wrap").forEach(function (cm_wrap) {
	const ipt = cm_wrap.querySelector('input');
	const myv = cm6(ipt.value, (v) => {
		ipt.value = v;
	});
	cm_wrap.appendChild(myv.dom);
	// const func = new Function(code);
	// func.call(context);
});


//  htmx.logAll();
htmx.config.useTemplateFragments = true;
// monitorEvents(htmx.find("#clients-table"));

document.body.addEventListener('htmx:confirm', function (evt) {
	evt.preventDefault();
	const confirmMessage = evt.target.dataset.confirmMessage;
	if (confirmMessage) {
		const cmo = JSON.parse(confirmMessage)
		Swal.fire(translateSwalCfg(cmo)).then((confirmed) => {
			if (confirmed && confirmed.isConfirmed) {
				evt.detail.issueRequest();
			}
		});
	} else {
		evt.detail.issueRequest();
	}
});

document.body.addEventListener('htmx:beforeSend', function (evt) {
	console.log(evt);
});


document.body.addEventListener('htmx:afterRequest', function (evt) {
	console.log(evt);
});


document.addEventListener("DOMContentLoaded", function () {
	// Toggle the dropdown menu visibility on button click
	const button = document.getElementById("dropdown-button");
	const menu = document.getElementById("dropdown-menu");

	button.addEventListener("click", function () {
		menu.classList.toggle("hidden");
	});

	// Close the dropdown when clicking outside of it
	document.addEventListener("click", function (event) {
		if (!button.contains(event.target) && !menu.contains(event.target)) {
			menu.classList.add("hidden");
		}
	});
});
