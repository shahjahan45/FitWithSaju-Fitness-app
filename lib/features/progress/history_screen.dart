import 'package:flutter/material.dart';
import '../../core/storage/local_store.dart';
import '../../core/theme/app_colors.dart';

class HistoryScreen extends StatefulWidget { const HistoryScreen({super.key}); @override State<HistoryScreen> createState()=>_HistoryScreenState(); }
class _HistoryScreenState extends State<HistoryScreen> {
  late Future<List<Map<String,dynamic>>> data;
  @override void initState(){ super.initState(); data=LocalStore.history(); }
  @override Widget build(BuildContext context)=>Scaffold(appBar:AppBar(title:const Text('Workout History')), body:FutureBuilder<List<Map<String,dynamic>>>(future:data,builder:(context,s){
    if(!s.hasData) return const Center(child:CircularProgressIndicator()); final items=s.data!;
    if(items.isEmpty) return const Center(child:Padding(padding:EdgeInsets.all(32),child:Text('Complete your first workout and it will appear here.',textAlign:TextAlign.center,style:TextStyle(color:AppColors.muted))));
    return ListView.builder(padding:const EdgeInsets.all(20),itemCount:items.length,itemBuilder:(_,i){final x=items[i]; final dt=DateTime.tryParse(x['date']??''); return Container(margin:const EdgeInsets.only(bottom:12),padding:const EdgeInsets.all(17),decoration:BoxDecoration(color:AppColors.surface,borderRadius:BorderRadius.circular(22),border:Border.all(color:AppColors.border)),child:Row(children:[const CircleAvatar(backgroundColor:Color(0x22FF7A00),child:Icon(Icons.fitness_center_rounded,color:AppColors.primary)),const SizedBox(width:14),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(x['title']??'Workout',style:const TextStyle(fontWeight:FontWeight.w900)),const SizedBox(height:4),Text(dt==null?'Saved workout':'${dt.day}/${dt.month}/${dt.year} • ${x['durationMinutes']} min • ${x['completedSets']} sets',style:const TextStyle(color:AppColors.muted,fontSize:12))]))]));});
  }));
}
