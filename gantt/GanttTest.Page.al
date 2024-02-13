page 50150 "Gantt Test"
{
    PageType = Card;
    Caption = 'Gantt Project';
    DataCaptionExpression = Rec.Description;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = Job;
    layout
    {
        area(Content)
        {
            usercontrol(Gantt; gantt)
            {
                ApplicationArea = All;
                trigger ControlReady()
                begin
                    CurrPage.Gantt.Load(JobAsJson(Rec));
                end;

            }
        }
    }
    procedure JobAsJson(JobRec: Record Job): JsonObject
    var
        JobTask: Record "Job Task";
        out: JsonObject;
        project: JsonObject;
        task: JsonObject;
        tasks: JsonArray;
        links: JsonArray;
        null: JsonValue;
        id: Integer;
        SerText: Text;
    begin

        null.SetValueToNull();
        id := 1;
        project.Add('id', 1);
        project.Add('text', JobRec.Description);
        project.Add('start_date', null);
        project.Add('duration', null);
        project.Add('parent', 0);
        project.Add('progress', 0);
        project.Add('open', true);
        tasks.Add(project);


        JobTask.SetRange("Job No.", JobRec."No.");


        if JobTask.FindSet() then
            repeat
                Clear(task);
                id += 1;

                case JobTask."Job Task Type" of
                    JobTask."Job Task Type"::"Begin-Total":
                        begin

                            JobTask.CalcFields("Start Date");
                            JobTask.CalcFields("End Date");
                            task.Add('id', id);
                            task.Add('text', JobTask.Description);
                            task.Add('start_date', null);
                            task.Add('duration', null);
                            if JobTask.Indentation = 0 then
                                task.Add('parent', 1)
                            else
                                task.Add('parent', id - 1);
                            task.Add('progress', 0);
                            tasks.add(task);
                        end;
                    JobTask."Job Task Type"::Posting:
                        begin
                            JobTask.CalcFields("Start Date");
                            JobTask.CalcFields("End Date");
                            task.Add('id', id);
                            task.Add('text', JobTask.Description);
                            task.Add('start_date', JobTask."Start Date");
                            task.Add('duration', JobTask."End Date" - JobTask."Start Date" + 1);
                            if JobTask.Indentation = 0 then
                                task.Add('parent', 1)
                            else
                                task.Add('parent', id - 1);
                            task.Add('progress', 0);
                            tasks.add(task);
                        end;
                end;
            until JobTask.Next = 0;
        out.Add('data', tasks);
        out.Add('links', links);
        exit(out);
    end;

}