@isTest
public with sharing class testqueueable extends BatchJobBase implements Queueable{
    public testqueueable() {

    }

    public void execute(QueueableContext QC){
        System.attachFinalizer(this);
    }
}