export class CreateMessageDto {
  projectId: string;
  content: string;
  senderType: 'STUDENT' | 'SUPERVISOR';
  senderId: string;
  senderName: string;
}
