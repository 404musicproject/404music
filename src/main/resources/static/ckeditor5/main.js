/**
 * This configuration was generated using the CKEditor 5 Builder. You can modify it anytime using this link:
 * https://ckeditor.com/ckeditor-5/builder/#installation/NoNgNARATAdAnDAjBSBmALHdB2ADL7EAVnUShBGwA490K9sjci4q4pc4iqKoaoUEANYB7FLjDBEYCROnyAupAAmVZeigBjAQqA==
 */

const {
	ClassicEditor,
	Autosave,
	Essentials,
	Paragraph,
	ImageUtils,
	ImageEditing,
	Bold,
	Italic,
	FontBackgroundColor,
	FontColor,
	FontSize,
	Highlight,
	Heading,
	Link,
	AutoLink,
	BlockQuote,
	HorizontalLine,
	Indent,
	Alignment,
	ImageInline,
	ImageToolbar,
	ImageBlock,
	ImageInsertViaUrl,
	AutoImage,
	ImageStyle,
	List,
	TodoList,
	Table,
	TableToolbar,
	PlainTableOutput
} = window.CKEDITOR;

const LICENSE_KEY =
	'eyJhbGciOiJFUzI1NiJ9.eyJleHAiOjE3NzA1MDg3OTksImp0aSI6IjVmMGMyYzdhLTkyZDktNGYyOC05OTc4LTg2OWU1YjA0ZGFmNiIsInVzYWdlRW5kcG9pbnQiOiJodHRwczovL3Byb3h5LWV2ZW50LmNrZWRpdG9yLmNvbSIsImRpc3RyaWJ1dGlvbkNoYW5uZWwiOlsiY2xvdWQiLCJkcnVwYWwiLCJzaCJdLCJ3aGl0ZUxhYmVsIjp0cnVlLCJsaWNlbnNlVHlwZSI6InRyaWFsIiwiZmVhdHVyZXMiOlsiKiJdLCJ2YyI6IjA5NTZhNzAxIn0.DiArpz7DpIQIRdh-S03RJahicYeiXMS9WCNE27m6QeI7TkOL3H1b58RUc3Jrdv5PaOgGx8wN3xAyrfY9oY7o3A';

const editorConfig = {
	toolbar: {
		items: [
			'undo',
			'redo',
			'|',
			'heading',
			'|',
			'fontSize',
			'fontColor',
			'fontBackgroundColor',
			'|',
			'bold',
			'italic',
			'|',
			'horizontalLine',
			'link',
			'insertImageViaUrl',
			'insertTable',
			'highlight',
			'blockQuote',
			'|',
			'alignment',
			'|',
			'bulletedList',
			'numberedList',
			'todoList',
			'outdent',
			'indent'
		],
		shouldNotGroupWhenFull: false
	},
	plugins: [
		Alignment,
		AutoImage,
		AutoLink,
		Autosave,
		BlockQuote,
		Bold,
		Essentials,
		FontBackgroundColor,
		FontColor,
		FontSize,
		Heading,
		Highlight,
		HorizontalLine,
		ImageBlock,
		ImageEditing,
		ImageInline,
		ImageInsertViaUrl,
		ImageStyle,
		ImageToolbar,
		ImageUtils,
		Indent,
		Italic,
		Link,
		List,
		Paragraph,
		PlainTableOutput,
		Table,
		TableToolbar,
		TodoList
	],
	fontSize: {
		options: [10, 12, 14, 'default', 18, 20, 22],
		supportAllValues: true
	},
	heading: {
		options: [
			{
				model: 'paragraph',
				title: 'Paragraph',
				class: 'ck-heading_paragraph'
			},
			{
				model: 'heading1',
				view: 'h1',
				title: 'Heading 1',
				class: 'ck-heading_heading1'
			},
			{
				model: 'heading2',
				view: 'h2',
				title: 'Heading 2',
				class: 'ck-heading_heading2'
			},
			{
				model: 'heading3',
				view: 'h3',
				title: 'Heading 3',
				class: 'ck-heading_heading3'
			},
			{
				model: 'heading4',
				view: 'h4',
				title: 'Heading 4',
				class: 'ck-heading_heading4'
			},
			{
				model: 'heading5',
				view: 'h5',
				title: 'Heading 5',
				class: 'ck-heading_heading5'
			},
			{
				model: 'heading6',
				view: 'h6',
				title: 'Heading 6',
				class: 'ck-heading_heading6'
			}
		]
	},
	image: {
		toolbar: ['imageStyle:inline', 'imageStyle:wrapText', 'imageStyle:breakText']
	},
	language: 'ko',
	licenseKey: LICENSE_KEY,
	link: {
		addTargetToExternalLinks: true,
		defaultProtocol: 'https://',
		decorators: {
			toggleDownloadable: {
				mode: 'manual',
				label: 'Downloadable',
				attributes: {
					download: 'file'
				}
			}
		}
	},
	menuBar: {
		isVisible: true
	},
	placeholder: 'Type or paste your content here!',
	table: {
		contentToolbar: ['tableColumn', 'tableRow', 'mergeTableCells']
	}
};

// 수정 코드:
ClassicEditor.create(document.querySelector('#editor'), editorConfig)
    .then(editor => {
        window.editor = editor; // JSP에서 접근할 수 있도록 window 객체에 저장
    })
    .catch(error => {
        console.error(error);
    });

