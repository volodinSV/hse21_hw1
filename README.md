# hse21_hw1
## Подготовка исходных данных
Создадим папку для выполнения задания, а в ней - ссылки на исходные файлы
>mkdir hw1  
>cd hw1  
>ls /usr/share/data-minor-bioinf/assembly/* | xargs -tI{} ln -s {}

С помощью команды seqtk выбираем случайно 5 миллионов чтений типа paired-end и 1.5 миллиона чтений типа mate-pairs.
В качестве параметра -s укажем месяц и дату рождения
>seqtk sample -s509 oil_R1.fastq 5000000 > SUB_oil_R1.fastq  
>seqtk sample -s509 oil_R2.fastq 5000000 > SUB_oil_R2.fastq  
>seqtk sample -s509 oilMP_S4_L001_R1_001.fastq 1500000 > SUB_oilMP_S4_L001_R1_001.fastq  
>seqtk sample -s509 oilMP_S4_L001_R2_001.fastq 1500000 > SUB_oilMP_S4_L001_R2_001.fastq  

## Оценка качества чтений
### Оценка качества исходных чтений
С помощью программы fastQC оценим качество исходных чтений, сохранив результаты в папку fastqc
>mkdir fastqc  
>ls *.fastq | xargs -P 4 -tI{} fastqc -o fastqc {}

Объеденим полученные результаты в один отчёт с помощью multiqC
>mkdir multiqc  
>multiqc -o multiqc fastqc
#### Результаты
![image](https://user-images.githubusercontent.com/93263216/139384764-8709e2eb-d3bb-43f6-992d-435001e964fe.png)  
![image](https://user-images.githubusercontent.com/93263216/139384551-91ba573b-78f5-402e-bd29-00553680f7a2.png)

### Оценка качества подрезанных чтений
С помощью программ platanus_trim и platanus_internal_trim подрежем чтения по качеству и удалим праймеры
>platanus_trim SUB_oil_R1.fastq SUB_oil_R2.fastq  
>platanus_internal_trim SUB_oilMP_S4_L001_R1_001.fastq SUB_oilMP_S4_L001_R2_001.fastq  

После подрезания чтений удалим исходные .fastq файлы, полученные с помощью программы seqtk
>rm SUB*.fastq

Оценим качество подрезанных чтений и получим по ним общую статистику с помощью fastQC и multiQC
>mkdir fastqc_trimmed  
>ls * | xargs -P 4 -tI{} fastqc -o fastqc_trimmed {}  
>mkdir multiqc_trimmed  
>multiqc -o multiqc_trimmed fastqc_trimmed

#### Результаты
![image](https://user-images.githubusercontent.com/93263216/139387145-892b6a67-3429-4832-b3fe-f86f59f65660.png)  
![image](https://user-images.githubusercontent.com/93263216/139386961-eae5ff4f-4bc0-4eed-84e0-ba967e7f57aa.png)

### Выводы
Как видим, у подрезанных чтений длина последовательностей уменьшилась, качетсво чтений улучшилось, а адаптеры почти полностью были удалены в сравнении с результатами исходных чтений

## Сборка контигов
С помощью программы "platanus assemble" соберём контиги из подрезанных чтений  
>time platanus assemble  -o Poil -t 8 -m 32 -f SUB_oil_R1.fastq.trimmed SUB_oil_R2.fastq.trimmed 2> assemble.log

В результате получим файл "Poil_contig.fa", где хранятся все полученные контиги. Скопируем этот файл в каталог hse21_hw1/data под именем "contigs.fasta".
Для анализа полученных контигов воспользуемся скриптом script.sh
>./script.sh ./Poil_contig.fa

Результаты:
>TOTAL: 619  
SUM: 3926526  
LONGEST: 179304  
N50: 55039

TOTAL - общее кол-во контигов, SUM - общая длина контигов, LONGEST - длина самого длинного контига, N50 - статистика N50

## Сборка скаффолдов из контигов
С помощью программы "platanus scaffold" соберём скаффолды из контигов, а также из подрезанных чтений 
>time platanus scaffold -o Poil -t 8 -c Poil_contig.fa -IP1 SUB_oil_R1.fastq.trimmed SUB_oil_R2.fastq.trimmed -OP2 SUB_oilMP_S4_L001_R1_001.fastq.int_trimmed SUB_oilMP_S4_L001_R2_001.fastq.int_trimmed

В результате получим файл "Poil_scaffold.fa", где хранятся все полученные скаффолды. Скопируем этот файл в каталог hse21_hw1/data под именем "scaffolds.fasta".
Для анализа полученных контигов воспользуемся тем же скриптом script.sh  
Результаты:
>TOTAL: 73  
>SUM: 3875802  
>LONGEST: 3831746  
>N50: 3831746

## Самый длинный скаффолд
С помощью программы script.sh с ключом -N проанализируем количество гэпов в самом длинном скаффолде.
>./script.sh -N ./Poil_scaffold.fa

Результаты:
>amountN: 5879

С помощью программы "platanus gap_close" уменьшим количество гэпов с помощью подрезанных чтений, проанализируем количество гэпов и убедимся, что их стало меньше. Скоприуем этот файл в каталог hse21_wh1/data опд именем "contigs.fasta"
>time platanus gap_close -o Poil -t 8 -c Poil_scaffold.fa -IP1 SUB_oil_R1.fastq.trimmed SUB_oil_R2.fastq.trimmed -OP2 SUB_oilMP_S4_L001_R1_001.fastq.int_trimmed SUB_oilMP_S4_L001_R2_001.fastq.int_trimmed  
>./script.sh -N ./Poil_gapClosed.fa

Результаты:
>amountN_gap: 963

## Конец
Удаляем все ненужные файлы командой rm и создаём репозиторий с помощью git
>git init  
>git add .  
>git commit -m 'initial commit'  
>git remote add origin https://github.com/username/projectname.git  
>git push -u origin master

Вводим логин и PAT токен для регистрации
