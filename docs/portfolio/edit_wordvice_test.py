from docx import Document
import copy

# Open the original
doc = Document(r'C:\Users\Admin\Downloads\Wordvice_EDITOR SAMPLE TEST_20200526.docx')

# Find and edit specific paragraphs
for i, para in enumerate(doc.paragraphs):
    text = para.text
    
    # Technology Passage Title
    if 'Data-driven Smart Home System for Elderly People ased' in text:
        for run in para.runs:
            if 'ased' in run.text:
                run.text = run.text.replace('ased', 'Based')
    
    # Abstract paragraph - Technology
    if 'The proportion of elderly people over 65 years has rapidly increased and social related' in text:
        for run in para.runs:
            run.text = run.text.replace('social related to aging', 'social issues related to aging')
            run.text = run.text.replace('The governments want', 'Governments want')
            run.text = run.text.replace('evaluates health conditions  reports', 'evaluates health condition reports')
            run.text = run.text.replace('self-reports', 'Self-reports')
            run.text = run.text.replace('To fix the problems', 'To address these problems')
            run.text = run.text.replace('In this paper, we a data-driven', 'In this paper, we propose a data-driven')
            run.text = run.text.replace('web technologies for connecting', 'web technologies to connect')
            run.text = run.text.replace('proposed ystem', 'proposed system')
            run.text = run.text.replace('provides a method elderly', 'provides a method for monitoring elderly')
            run.text = run.text.replace('and to register', 'and registers')
            run.text = run.text.replace('controls actuators', 'It controls actuators')
            run.text = run.text.replace('shows a summary of activities to .', 'shows users a summary of activities.')
    
    # Introduction paragraph - Technology
    if 'in life expectancy the proportion' in text:
        for run in para.runs:
            run.text = run.text.replace('in life expectancy the proportion', 'With increases in life expectancy, the proportion')
            run.text = run.text.replace('rapidly increased', 'have rapidly increased')
            run.text = run.text.replace('population globally and the social cost', 'population globally, and the social costs')
            run.text = run.text.replace('related to aging is difficult', 'related to aging make it difficult')
            run.text = run.text.replace(' elderly people are exposed', ' Elderly people are exposed')
            run.text = run.text.replace(' elderly people need', ' As elderly people need')
            run.text = run.text.replace('used such as', 'used, such as')
            run.text = run.text.replace('is a way  people', 'is a way of assessing people')
            run.text = run.text.replace('tend do every', 'tend to do every')
            run.text = run.text.replace('IADL not necessary', 'IADLs are not necessary')
            run.text = run.text.replace('and an independent', 'but are necessary for an independent')
            run.text = run.text.replace('reported  these', 'reported through these')
            run.text = run.text.replace('can be more .', 'can be more accurate.')
            run.text = run.text.replace(' solve these', ' To solve these')
    
    # IoT paragraph
    if 'Internet of (IoT)' in text:
        for run in para.runs:
            run.text = run.text.replace('Internet of (IoT)', 'Internet of Things (IoT)')
            run.text = run.text.replace('with the advent', 'With the advent')

# Save edited version
out = r'C:\Users\Admin\Downloads\Wordvice_EDITOR_SAMPLE_TEST_EDITED.docx'
doc.save(out)
print(f'Edited file saved: {out}')
