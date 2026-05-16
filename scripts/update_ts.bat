cd ..
pyside6-lupdate fluentqml/ -ts fluentqml/languages/en_US.ts
pyside6-lupdate fluentqml/ -ts fluentqml/languages/zh_CN.ts

pyside6-lrelease fluentqml/languages/en_US.ts
pyside6-lrelease fluentqml/languages/zh_CN.ts
