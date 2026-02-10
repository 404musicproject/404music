// main.js

const LICENSE_KEY = 'eyJhbGciOiJFUzI1NiJ9.eyJleHAiOjE4MDA4MzUxOTksImp0aSI6ImQ0ZTI0NGI0LTZkODQtNDlhOS1iN2FkLTA2MWM1MjAwNjA4MCIsImxpY2Vuc2VkSG9zdHMiOlsiMTI3LjAuMC4xIiwibG9jYWxob3N0IiwiMTkyLjE2OC4qLioiLCIxMC4qLiouKiIsIjE3Mi4qLiouKiIsIioudGVzdCIsIioubG9jYWxob3N0IiwiKi5sb2NhbCJdLCJ1c2FnZUVuZHBvaW50IjoiaHR0cHM6Ly9wcm94eS1ldmVudC5ja2VkaXRvci5jb20iLCJkaXN0cmlidXRpb25DaGFubmVsIjpbImNsb3VkIiwiZHJ1cGFsIl0sImxpY2Vuc2VUeXBlIjoiZGV2ZWxvcG1lbnQiLCJmZWF0dXJlcyI6WyJEUlVQIiwiRTJQIiwiRTJXIl0sInJlbW92ZUZlYXR1cmVzIjpbIlBCIiwiUkYiLCJTQ0giLCJUQ1AiLCJUTCIsIlRDUiIsIklSIiwiU1VBIiwiQjY0QSIsIkxQIiwiSEUiLCJSRUQiLCJQRk8iLCJXQyIsIkZBUiIsIkJLTSIsIkZQSCIsIk1SRSJdLCJ2YyI6IjlkOGEwMzk5In0.pfQoAuy4ny8jmSg93ORw5sPgludqtVcApEtgFc5Kw5FJbiejFgpfnrD5bBZcHR719PMQSRJ4vDpx9bU4GkEj2g';

CKEDITOR.ClassicEditor
    .create(document.querySelector('#editor'), {
        licenseKey: LICENSE_KEY,
        language: 'ko',
        // 1. 툴바 설정
        toolbar: [
            'undo', 'redo', '|', 'heading', '|', 
            'fontSize', 'fontColor', 'fontBackgroundColor', '|',
            'bold', 'italic', 'strikethrough', 'underline', '|',
            'alignment', 'link', 'uploadImage', 'insertTable', 'highlight', '|',
            'bulletedList', 'numberedList', 'todoList', '|', 'outdent', 'indent'
        ],
        // 2. 서버 업로드 설정 (SimpleUpload)
        // 만약 서버 처리가 귀찮다면 이 부분을 지우고 removePlugins에서 Base64UploadAdapter를 빼세요.
        simpleUpload: {
            uploadUrl: '/support/Notification', 
            withCredentials: true
        },
        // 3. 충돌 플러그인 제거
        removePlugins: [
            'CKBox', 'CKFinder', 'EasyImage', 
            // 'Base64UploadAdapter', // 서버 전송 대신 바로 보이게 하려면 이 줄을 주석 처리하세요.
            'TableOfContents', 'FormatPainter', 'Template', 'SlashCommand',
            'PasteFromOfficeEnhanced', 'CaseChange', 'AIAssistant', 'AIAssistantUI',
            'AIAdapter', 'DocumentOutline', 'Pagination', 'WProofreader',
            'RealTimeCollaborativeComments', 'RealTimeCollaborativeTrackChanges',
            'RealTimeCollaborativeRevisionHistory', 'PresenceList', 'Comments',
            'TrackChanges', 'TrackChangesData', 'RevisionHistory',
            'CommentsRepository', 'RealTimeCollaborationClient',
            'ExportPdf', 'ExportWord'
        ]
    })
    .then(editor => {
        window.editor = editor;
        console.log('에디터 초기화 및 업로드 준비 완료!');
    })
    .catch(error => {
        console.error('에디터 초기화 실패:', error);
    });