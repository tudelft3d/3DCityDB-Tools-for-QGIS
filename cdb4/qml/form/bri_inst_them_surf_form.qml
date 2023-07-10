<!DOCTYPE qgis PUBLIC 'http://mrcc.com/qgis.dtd' 'SYSTEM'>
<qgis styleCategories="Fields|Forms" version="3.22.7-Białowieża">
  <fieldConfiguration>
<!-- cityobject attributes -->
    <field configurationFlags="None" name="id">
      <editWidget type="TextEdit"></editWidget>
    </field>
    <field configurationFlags="None" name="gmlid">
      <editWidget type="TextEdit"></editWidget>
    </field>
    <field configurationFlags="None" name="gmlid_codespace">
      <editWidget type="TextEdit"></editWidget>
    </field>
    <field configurationFlags="None" name="name">
      <editWidget type="TextEdit"></editWidget>
    </field>
    <field configurationFlags="None" name="name_codespace">
      <editWidget type="TextEdit"></editWidget>
    </field>
    <field configurationFlags="None" name="description">
      <editWidget type="TextEdit"></editWidget>
    </field>
    <field configurationFlags="None" name="creation_date">
      <editWidget type="DateTime">
        <config>
          <Option type="Map">
            <Option name="allow_null" value="true" type="bool"/>
            <Option name="calendar_popup" value="true" type="bool"/>
            <Option name="display_format" value="dd-MM-yyyy HH:mm:ss" type="QString"/>
            <Option name="field_format" value="dd-MM-yyyy HH:mm:ss" type="QString"/>
            <Option name="field_iso_format" value="false" type="bool"/>
          </Option>
        </config>
	  </editWidget>
    </field>
    <field configurationFlags="None" name="termination_date">
      <editWidget type="DateTime">
        <config>
          <Option type="Map">
            <Option name="allow_null" value="true" type="bool"/>
            <Option name="calendar_popup" value="true" type="bool"/>
            <Option name="display_format" value="dd-MM-yyyy HH:mm:ss" type="QString"/>
            <Option name="field_format" value="dd-MM-yyyy HH:mm:ss" type="QString"/>
            <Option name="field_iso_format" value="false" type="bool"/>
          </Option>
        </config>
	  </editWidget>
    </field>
    <field configurationFlags="None" name="relative_to_terrain">
      <editWidget type="ValueRelation">
        <config>
          <Option type="Map">
            <Option name="AllowMulti" value="false" type="bool"/>
            <Option name="AllowNull" value="true" type="bool"/>
            <Option name="FilterExpression" value="" type="QString"/>
            <Option name="Key" value="value" type="QString"/>
            <Option name="Layer" value="_v_enumeration_value_" type="QString"/>
            <Option name="NofColumns" value="1" type="int"/>
            <Option name="OrderByValue" value="false" type="bool"/>
            <Option name="UseCompleter" value="false" type="bool"/>
            <Option name="Value" value="description" type="QString"/>
          </Option>
        </config>
	  </editWidget>
    </field>
    <field configurationFlags="None" name="relative_to_water">
      <editWidget type="ValueRelation">
        <config>
          <Option type="Map">
            <Option name="AllowMulti" value="false" type="bool"/>
            <Option name="AllowNull" value="true" type="bool"/>
            <Option name="FilterExpression" value="" type="QString"/>
            <Option name="Key" value="value" type="QString"/>
            <Option name="Layer" value="_v_enumeration_value_" type="QString"/>
            <Option name="NofColumns" value="1" type="int"/>
            <Option name="OrderByValue" value="false" type="bool"/>
            <Option name="UseCompleter" value="false" type="bool"/>
            <Option name="Value" value="description" type="QString"/>
          </Option>
        </config>
	  </editWidget>
    </field>
    <field configurationFlags="None" name="last_modification_date">
      <editWidget type="DateTime">
        <config>
          <Option type="Map">
            <Option name="allow_null" value="true" type="bool"/>
            <Option name="calendar_popup" value="true" type="bool"/>
            <Option name="display_format" value="dd-MM-yyyy HH:mm:ss" type="QString"/>
            <Option name="field_format" value="dd-MM-yyyy HH:mm:ss" type="QString"/>
            <Option name="field_iso_format" value="false" type="bool"/>
          </Option>
        </config>
	  </editWidget>
    </field>
    <field configurationFlags="None" name="updating_person">
      <editWidget type="TextEdit"></editWidget>
    </field>
    <field configurationFlags="None" name="reason_for_update">
      <editWidget type="TextEdit"></editWidget>
    </field>
    <field configurationFlags="None" name="lineage">
      <editWidget type="TextEdit"></editWidget>
    </field>
<!-- root/parent attributes -->
    <field configurationFlags="None" name="bridge_installation_id">
      <editWidget type="TextEdit"></editWidget>
    </field>
  </fieldConfiguration>
  <aliases>
    <alias index="0"  name="Database ID" field="id"/>
    <alias index="1"  name="GML ID" field="gmlid"/>
    <alias index="2"  name="GML codespace" field="gmlid_codespace"/>
    <alias index="3"  name="Name" field="name"/>
    <alias index="4"  name="Name codespace" field="name_codespace"/>
    <alias index="5"  name="Description" field="description"/>
    <alias index="6"  name="Creation date" field="creation_date"/>
    <alias index="7"  name="Termination date" field="termination_date"/>
    <alias index="8"  name="Relative to terrain" field="relative_to_terrain"/>
    <alias index="9"  name="Relative to water" field="relative_to_water"/>
    <alias index="10" name="Last modification" field="last_modification_date"/>
    <alias index="11" name="Updating person" field="updating_person"/>
    <alias index="12" name="Reason for update" field="reason_for_update"/>
    <alias index="13" name="Lineage" field="lineage"/>
<!-- parent/root attributes -->
    <alias index="101" name="Bridge installation ID" field="bridge_id"/>
  </aliases>
  <defaults></defaults>
  <constraints>
    <constraint constraints="3" exp_strength="0" notnull_strength="1" unique_strength="1" field="id"/>
  </constraints>
  <constraintExpressions></constraintExpressions>
  <expressionfields/>
  <editform tolerant="1"></editform>
  <editforminit/>
  <editforminitcodesource>0</editforminitcodesource>
  <editforminitfilepath></editforminitfilepath>
  <editforminitcode></editforminitcode>
  <featformsuppress>0</featformsuppress>
  <editorlayout>tablayout</editorlayout>
  <attributeEditorForm>
<!-- cityobject tab -->  
   <attributeEditorContainer name="Main Info" visibilityExpressionEnabled="0" showLabel="0" groupBox="0" visibilityExpression="" columnCount="2">
      <attributeEditorField name="id" showLabel="1" index="0"/>
      <attributeEditorField name="description" showLabel="1" index="5"/>
      <attributeEditorField name="gmlid" showLabel="1" index="1"/>
      <attributeEditorField name="gmlid_codespace" showLabel="1" index="2"/>
      <attributeEditorField name="name" showLabel="1" index="3"/>
      <attributeEditorField name="name_codespace" showLabel="1" index="4"/>
<!-- Parent/root attributes BEGIN -->
      <attributeEditorField name="bridge_installation_id" showLabel="1" index="101"/>
<!-- Parent/root attributes END -->	
    </attributeEditorContainer>
<!-- database info tab -->  
    <attributeEditorContainer name="Database Info" visibilityExpressionEnabled="0" showLabel="0" groupBox="0" visibilityExpression="" columnCount="2">
      <attributeEditorField name="creation_date" showLabel="1" index="6"/>
      <attributeEditorField name="termination_date" showLabel="1" index="7"/>
      <attributeEditorField name="last_modification_date" showLabel="1" index="10"/>
      <attributeEditorField name="updating_person" showLabel="1" index="11"/>
      <attributeEditorField name="reason_for_update" showLabel="1" index="12"/>
      <attributeEditorField name="lineage" showLabel="1" index="13"/>
    </attributeEditorContainer>
<!-- relation to surface tab -->  
    <attributeEditorContainer name="Relation to surface" visibilityExpressionEnabled="0" showLabel="0" groupBox="0" visibilityExpression="" columnCount="1">
      <attributeEditorField name="relative_to_terrain" showLabel="1" index="8"/>
      <attributeEditorField name="relative_to_water" showLabel="1" index="9"/>
    </attributeEditorContainer>
<!-- External references tabs -->
    <attributeEditorContainer name="Ext ref (Name)" visibilityExpressionEnabled="0" showLabel="0" groupBox="0" visibilityExpression="" columnCount="1">
      <attributeEditorRelation forceSuppressFormPopup="0" name="id_re_xx" relationWidgetTypeId="relation_editor" relation="id_xx" label="Form Ext ref (Name)" showLabel="0" nmRelationId="">
        <editor_configuration type="Map">
          <Option name="buttons" type="QString" value="SaveChildEdits|AddChildFeature|DuplicateChildFeature|DeleteChildFeature"/>
          <Option name="show_first_feature" type="bool" value="true"/>
        </editor_configuration>
      </attributeEditorRelation>
    </attributeEditorContainer>
    <attributeEditorContainer name="Ext ref (Uri)" visibilityExpressionEnabled="0" showLabel="0" groupBox="0" visibilityExpression="" columnCount="1">
      <attributeEditorRelation forceSuppressFormPopup="0" name="id_re_xx" relationWidgetTypeId="relation_editor" relation="id_re_xx" label="Form Ext ref (Uri)" showLabel="0" nmRelationId="">
        <editor_configuration type="Map">
          <Option name="buttons" type="QString" value="SaveChildEdits|AddChildFeature|DuplicateChildFeature|DeleteChildFeature"/>
          <Option name="show_first_feature" type="bool" value="true"/>
        </editor_configuration>
      </attributeEditorRelation>
    </attributeEditorContainer>
<!-- just an empty line -->
    <attributeEditorQmlElement name="QmlWidget" showLabel="0"></attributeEditorQmlElement>
<!-- Generic attributes tabs -->
    <attributeEditorContainer name="Gen Attrib (String)" visibilityExpressionEnabled="0" showLabel="0" groupBox="0" visibilityExpression="" columnCount="1">
      <attributeEditorRelation forceSuppressFormPopup="0" name="id_re_xx" relationWidgetTypeId="relation_editor" relation="id_re_xx" label="Form Gen Attrib (String)" showLabel="0" nmRelationId="">
        <editor_configuration type="Map">
          <Option name="buttons" type="QString" value="SaveChildEdits|AddChildFeature|DuplicateChildFeature|DeleteChildFeature"/>
          <Option name="show_first_feature" type="bool" value="true"/>
        </editor_configuration>
      </attributeEditorRelation>
    </attributeEditorContainer>
    <attributeEditorContainer name="Gen Attrib (Integer)" visibilityExpressionEnabled="0" showLabel="0" groupBox="0" visibilityExpression="" columnCount="1">
      <attributeEditorRelation forceSuppressFormPopup="0" name="id_re_xx" relationWidgetTypeId="relation_editor" relation="id_re_xx" label="Form Gen Attrib (Integer)" showLabel="0" nmRelationId="">
        <editor_configuration type="Map">
          <Option name="buttons" type="QString" value="SaveChildEdits|AddChildFeature|DuplicateChildFeature|DeleteChildFeature"/>
          <Option name="show_first_feature" type="bool" value="true"/>
        </editor_configuration>
      </attributeEditorRelation>
    </attributeEditorContainer>
    <attributeEditorContainer name="Gen Attrib (Real)" visibilityExpressionEnabled="0" showLabel="0" groupBox="0" visibilityExpression="" columnCount="1">
      <attributeEditorRelation forceSuppressFormPopup="0" name="id_re_xx" relationWidgetTypeId="relation_editor" relation="id_re_xx" label="Form Gen Attrib (Real)" showLabel="0" nmRelationId="">
        <editor_configuration type="Map">
          <Option name="buttons" type="QString" value="SaveChildEdits|AddChildFeature|DuplicateChildFeature|DeleteChildFeature"/>
          <Option name="show_first_feature" type="bool" value="true"/>
        </editor_configuration>
      </attributeEditorRelation>
    </attributeEditorContainer>
    <attributeEditorContainer name="Gen Attrib (Measure)" visibilityExpressionEnabled="0" showLabel="0" groupBox="0" visibilityExpression="" columnCount="1">
      <attributeEditorRelation forceSuppressFormPopup="0" name="id_xx" relationWidgetTypeId="relation_editor" relation="id_re_xx" label="Form Gen Attrib (Measure)" showLabel="0" nmRelationId="">
        <editor_configuration type="Map">
          <Option name="buttons" type="QString" value="SaveChildEdits|AddChildFeature|DuplicateChildFeature|DeleteChildFeature"/>
          <Option name="show_first_feature" type="bool" value="true"/>
        </editor_configuration>
      </attributeEditorRelation>
    </attributeEditorContainer>
    <attributeEditorContainer name="Gen Attrib (Date)" visibilityExpressionEnabled="0" showLabel="0" groupBox="0" visibilityExpression="" columnCount="1">
      <attributeEditorRelation forceSuppressFormPopup="0" name="id_re_xx" relationWidgetTypeId="relation_editor" relation="id_re_xx" label="Form Gen Attrib (Date)" showLabel="0" nmRelationId="">
        <editor_configuration type="Map">
          <Option name="buttons" type="QString" value="SaveChildEdits|AddChildFeature|DuplicateChildFeature|DeleteChildFeature"/>
          <Option name="show_first_feature" type="bool" value="true"/>
        </editor_configuration>
      </attributeEditorRelation>
    </attributeEditorContainer>
    <attributeEditorContainer name="Gen Attrib (Uri)" visibilityExpressionEnabled="0" showLabel="0" groupBox="0" visibilityExpression="" columnCount="1">
      <attributeEditorRelation forceSuppressFormPopup="0" name="id_re_xx" relationWidgetTypeId="relation_editor" relation="id_re_xx" label="Form Gen Attrib (Uri)" showLabel="0" nmRelationId="">
        <editor_configuration type="Map">
          <Option name="buttons" type="QString" value="SaveChildEdits|AddChildFeature|DuplicateChildFeature|DeleteChildFeature"/>
          <Option name="show_first_feature" type="bool" value="true"/>
        </editor_configuration>
      </attributeEditorRelation>
    </attributeEditorContainer>
<!--     <attributeEditorContainer name="Gen Attrib (Blob)" visibilityExpressionEnabled="0" showLabel="0" groupBox="0" visibilityExpression="" columnCount="1">
      <attributeEditorRelation forceSuppressFormPopup="0" name="" relationWidgetTypeId="relation_editor" relation="" label="Gen Attrib (Blob) child form" showLabel="0" nmRelationId="">
        <editor_configuration type="Map">
          <Option name="buttons" type="QString" value="SaveChildEdits|AddChildFeature|DuplicateChildFeature|DeleteChildFeature"/>
          <Option name="show_first_feature" type="bool" value="true"/>
        </editor_configuration>
      </attributeEditorRelation>
    </attributeEditorContainer> -->
<!-- just an empty line -->
  </attributeEditorForm>
  <editable>
    <field editable="0" name="id"/>
    <field editable="0" name="gmlid"/>
    <field editable="0" name="gmlid_codespace"/>
    <field editable="0" name="name_codespace"/>
    <field editable="0" name="creation_date"/>	
    <field editable="0" name="termination_date"/>
    <field editable="0" name="last_modification_date"/>
    <field editable="0" name="updating_person"/>
    <field editable="0" name="lineage"/>
<!-- parent and root attributes -->
    <field editable="0" name="bridge_installation_id"/>
  </editable>
  <labelOnTop></labelOnTop>
  <reuseLastValue></reuseLastValue>
  <dataDefinedFieldProperties/>
  <widgets/>
</qgis>
