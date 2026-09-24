import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../data/demo_repository.dart';

class CustomWorkoutScreen extends StatefulWidget { const CustomWorkoutScreen({super.key}); @override State<CustomWorkoutScreen> createState()=>_CustomWorkoutScreenState(); }
class _CustomWorkoutScreenState extends State<CustomWorkoutScreen>{
 final name=TextEditingController(text:'My Workout'); final Set<String> selected={};
 @override void dispose(){name.dispose();super.dispose();}
 @override Widget build(BuildContext context)=>Scaffold(appBar:AppBar(title:const Text('Create Workout')),body:ListView(padding:const EdgeInsets.all(20),children:[
   TextField(controller:name,decoration:const InputDecoration(labelText:'Workout name',prefixIcon:Icon(Icons.edit_rounded))),const SizedBox(height:22),
   const Text('Choose exercises',style:TextStyle(fontSize:18,fontWeight:FontWeight.w900)),const SizedBox(height:12),
   ...DemoRepository.exercises.map((e)=>CheckboxListTile(value:selected.contains(e.id),onChanged:(v)=>setState((){v==true?selected.add(e.id):selected.remove(e.id);}),activeColor:AppColors.primary,checkColor:Colors.black,secondary:const Icon(Icons.fitness_center_rounded,color:AppColors.secondary),title:Text(e.name,style:const TextStyle(fontWeight:FontWeight.w800)),subtitle:Text('${e.muscle} • ${e.equipment}',style:const TextStyle(color:AppColors.muted)),shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(18)),contentPadding:const EdgeInsets.symmetric(horizontal:12))),
   const SizedBox(height:18),SizedBox(height:58,child:FilledButton.icon(style:FilledButton.styleFrom(backgroundColor:AppColors.primary,foregroundColor:Colors.black,shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(20))),onPressed:selected.isEmpty?null:(){ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text('${name.text} created with ${selected.length} exercises. Local full persistence is the next refinement.')));},icon:const Icon(Icons.save_rounded),label:const Text('Save Workout',style:TextStyle(fontWeight:FontWeight.w900))))
 ]));
}
